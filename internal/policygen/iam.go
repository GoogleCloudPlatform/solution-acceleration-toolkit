// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package policygen

import (
	"encoding/json"
	"fmt"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/hashicorp/terraform/states"
)

type root struct {
	Type string
	ID   string
}

// All IAM members associated with a single role.
type roleBindings map[string][]string

func generateIAMPolicies(rn runner.Runner, resources []*states.Resource, outputPath, templateDir string) error {
	bindings, err := allBindings(rn, resources)
	if err != nil {
		return err
	}

	for root, rbs := range bindings {
		outputFolder := fmt.Sprintf("%s_%s", root.Type, root.ID)
		// Generate policies for allowed roles.
		data := map[string]interface{}{
			"target": fmt.Sprintf("%s/%s", root.Type, root.ID),
			"roles":  rbs,
		}
		in := filepath.Join(templateDir, "forseti", "tf_based", "iam_allow_roles.yaml")
		out := filepath.Join(outputPath, forsetiOutputRoot, outputFolder, "iam_allow_roles.yaml")
		if err := template.WriteFile(in, out, data); err != nil {
			return err
		}

		// Generate policies for allowed bindings for each role.
		for role, bindings := range rbs {
			data := map[string]interface{}{
				"target":   fmt.Sprintf("%s/%s", root.Type, root.ID),
				"role":     role,
				"bindings": bindings,
			}
			in := filepath.Join(templateDir, "forseti", "tf_based", "iam_allow_bindings.yaml")
			out := filepath.Join(outputPath, forsetiOutputRoot, outputFolder, fmt.Sprintf("iam_allow_bindings_%s.yaml", strings.TrimPrefix(role, "roles/")))
			if err := template.WriteFile(in, out, data); err != nil {
				return err
			}
		}
	}
	return nil
}

func allBindings(rn runner.Runner, resources []*states.Resource) (map[root]roleBindings, error) {

	// All roles associated with a root resource (organization, folder or project).
	var bindings = make(map[root]roleBindings)

	typeToIDField := map[string]string{
		"project":      "project",
		"folder":       "folder",
		"organization": "org_id",
	}

	for t, idField := range typeToIDField {
		// TODO(https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/issues/152): Support google_*_iam_bindings.
		resourceType := fmt.Sprintf("google_%s_iam_member", t)
		instances, err := terraform.GetInstancesForType(resources, resourceType)
		if err != nil {
			return nil, fmt.Errorf("get resource instances for type %q: %v", resourceType, err)
		}

		for _, ins := range instances {
			if err := validate(ins, []string{idField, "role", "member"}); err != nil {
				return nil, err
			}

			id := ins[idField].(string) // Type checked in validate()
			// For projects, the ID in the state is the project ID, but we need project number in policies.
			if t == "project" {
				if id, err = projectNumber(rn, id); err != nil {
					return nil, err
				}
			}

			key := root{Type: t, ID: id}

			// Init the roleBindings map if it didn't exist.
			if _, ok := bindings[key]; !ok {
				bindings[key] = make(roleBindings)
			}

			role := ins["role"].(string)
			bindings[key][role] = append(bindings[key][role], ins["member"].(string))
		}
	}
	return bindings, nil
}

// validate checks the presence of mandatory fields and assert string type.
func validate(instance map[string]interface{}, mandatoryFields []string) error {
	for _, k := range mandatoryFields {
		if _, ok := instance[k]; !ok {
			return fmt.Errorf("mandatory field %q missing from instance: %v", k, instance)
		}
		if _, ok := instance[k].(string); !ok {
			return fmt.Errorf("value for %q should be a string, got %T", k, instance[k])
		}
	}
	return nil
}

func projectNumber(rn runner.Runner, id string) (string, error) {
	cmd := exec.Command("gcloud", "projects", "describe", id, "--format", "json")
	out, err := rn.CmdOutput(cmd)
	if err != nil {
		return "", fmt.Errorf("failed to get project number for project %q: %v", id, err)
	}

	type project struct {
		ProjectNumber string `json:"projectNumber"`
	}

	var p project
	if err := json.Unmarshal(out, &p); err != nil {
		return "", fmt.Errorf("failed to parse project number from gcloud output: %v", err)
	}

	if p.ProjectNumber == "" {
		return "", fmt.Errorf("project number is empty")
	}

	return p.ProjectNumber, nil
}
