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
	"sort"
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
			// organizations/1234, folders/1234, projects/1234
			"target": fmt.Sprintf("%ss/%s", root.Type, root.ID),
			"roles":  rbs,
			// Also prepend type and id in the policy name to make it unique across multiple policies for the same role.
			"suffix": fmt.Sprintf("%s_%s", root.Type, root.ID),
		}
		in := filepath.Join(templateDir, "forseti", "tf_based", "iam_allow_roles.yaml")
		out := filepath.Join(outputPath, outputFolder, "iam_allow_roles.yaml")
		if err := template.WriteFile(in, out, data); err != nil {
			return err
		}

		// Generate policies for allowed bindings for each role.
		for role, members := range rbs {
			// Removes any prefix before the role name ('roles/' or 'projects/<my-project>/roles/' for a custom role).
			// Prepend 'custom_' if custom role.
			// Replaces '.' with '_'  and turns each character to lower case.
			// E.g. roles/orgpolicy.policyViewer --> orgpolicy_policyviewer
			//      projects/<my-project>/roles/osLoginProjectGet_6afd --> custom_osloginprojectget_6afd
			suffix := role
			// Predefined roles, e.g. roles/orgpolicy.policyViewer.
			if strings.HasPrefix(suffix, "roles/") {
				suffix = strings.TrimPrefix(suffix, "roles/")
			} else { // Custom roles, e.g. projects/<my-project>/roles/osLoginProjectGet_6afd.
				segs := strings.Split(suffix, "/")
				suffix = "custom_" + segs[len(segs)-1]
			}
			suffix = strings.ToLower(strings.Replace(suffix, ".", "_", -1))

			data := map[string]interface{}{
				// organizations/1234, folders/1234, projects/1234
				"target": fmt.Sprintf("%ss/%s", root.Type, root.ID),
				// Also prepend type and id in the policy name to make it unique across multiple policies for the same role.
				"suffix":  fmt.Sprintf("%s_%s_%s", root.Type, root.ID, suffix),
				"role":    role,
				"members": members,
			}
			in := filepath.Join(templateDir, "forseti", "tf_based", "iam_allow_bindings.yaml")
			out := filepath.Join(outputPath, outputFolder, fmt.Sprintf("iam_allow_bindings_%s.yaml", suffix))
			if err := template.WriteFile(in, out, data); err != nil {
				return err
			}
		}
	}
	return nil
}

func allBindings(rn runner.Runner, resources []*states.Resource) (map[root]roleBindings, error) {

	// All roles associated with a root resource (organization, folder or project).
	var allBindings = make(map[root]roleBindings)

	typeToIDField := map[string]string{
		"project":      "project",
		"folder":       "folder",
		"organization": "org_id",
	}

	for rootType, idField := range typeToIDField {
		iamMembers, err := members(rn, resources, rootType, idField)
		if err != nil {
			return nil, err
		}

		iamBindings, err := bindings(rn, resources, rootType, idField)
		if err != nil {
			return nil, err
		}

		// Add iamBindings to iamMembers.
		// If iamMembers have members for the same root and role, replace it with the value from iamBindings.
		for root, bindings := range iamBindings {
			for role, members := range bindings {
				// Init the roleBindings map if it didn't exist.
				if _, ok := iamMembers[root]; !ok {
					iamMembers[root] = make(roleBindings)
				}
				iamMembers[root][role] = members
			}
		}
		for root, bindings := range iamMembers {
			for role, members := range bindings {
				// Remove duplicated members for the same role.
				bindings[role] = unique(members)
			}
			allBindings[root] = bindings
		}
	}
	return allBindings, nil
}

func unique(in []string) []string {
	keys := make(map[string]bool)
	var out []string
	for _, s := range in {
		if _, exists := keys[s]; !exists {
			keys[s] = true
			out = append(out, s)
		}
	}
	sort.Strings(out)
	return out
}

// members returns role bindings map for google_%s_iam_member (non-authoritative).
func members(rn runner.Runner, resources []*states.Resource, rootType, idField string) (map[root]roleBindings, error) {
	var bindings = make(map[root]roleBindings)
	resourceType := fmt.Sprintf("google_%s_iam_member", rootType) // non-authoritative
	instances, err := terraform.GetInstancesForType(resources, resourceType)
	if err != nil {
		return nil, fmt.Errorf("get resource instances for type %q: %v", resourceType, err)
	}

	for _, ins := range instances {
		if err := validateMandatoryStringFields(ins, []string{idField, "role", "member"}); err != nil {
			return nil, err
		}

		id, err := normalizeID(rn, rootType, ins[idField].(string)) // Type checked in validate function.
		if err != nil {
			return nil, fmt.Errorf("normalize root resource ID: %v", err)
		}

		key := root{Type: rootType, ID: id}

		// Init the roleBindings map if it didn't exist.
		if _, ok := bindings[key]; !ok {
			bindings[key] = make(roleBindings)
		}

		role := ins["role"].(string)
		bindings[key][role] = append(bindings[key][role], ins["member"].(string))
	}
	return bindings, nil
}

// bindings returns role bindings map for google_%s_iam_binding (authoritative).
func bindings(rn runner.Runner, resources []*states.Resource, rootType, idField string) (map[root]roleBindings, error) {
	var bindings = make(map[root]roleBindings)
	resourceType := fmt.Sprintf("google_%s_iam_binding", rootType) // authoritative for a given role
	instances, err := terraform.GetInstancesForType(resources, resourceType)
	if err != nil {
		return nil, fmt.Errorf("get resource instances for type %q: %v", resourceType, err)
	}

	for _, ins := range instances {
		if err := validateMandatoryStringFields(ins, []string{idField, "role"}); err != nil {
			return nil, err
		}
		if err := validateMandatoryStringLists(ins, []string{"members"}); err != nil {
			return nil, err
		}

		id, err := normalizeID(rn, rootType, ins[idField].(string)) // Type checked in validate function.
		if err != nil {
			return nil, fmt.Errorf("normalize root resource ID: %v", err)
		}

		key := root{Type: rootType, ID: id}

		// Init the roleBindings map if it didn't exist.
		if _, ok := bindings[key]; !ok {
			bindings[key] = make(roleBindings)
		}

		role := ins["role"].(string)

		var members []string
		for _, s := range ins["members"].([]interface{}) {
			members = append(members, s.(string)) // Type checked in validate function.
		}

		// There should not be more than one instance of google_%s_iam_binding for the same resource
		// across all states. But we append all members just in case.
		bindings[key][role] = append(bindings[key][role], members...)
	}
	return bindings, nil
}

// validateMandatoryStringFields checks the presence of mandatory fields and assert string type.
func validateMandatoryStringFields(instance map[string]interface{}, mandatoryFields []string) error {
	for _, k := range mandatoryFields {
		field, ok := instance[k]
		if !ok {
			return fmt.Errorf("mandatory field %q missing from instance: %v", k, instance)
		}
		if _, ok := field.(string); !ok {
			return fmt.Errorf("value for %q should be a string, got %T", k, field)
		}
	}
	return nil
}

// validateMandatoryLists checks the presence of mandatory fields and assert []interface{} type.
func validateMandatoryStringLists(instance map[string]interface{}, mandatoryFields []string) error {
	for _, k := range mandatoryFields {
		field, ok := instance[k]
		if !ok {
			return fmt.Errorf("mandatory field %q missing from instance: %v", k, instance)
		}
		lst, ok := field.([]interface{})
		if !ok {
			return fmt.Errorf("value for %q should be a []interface{}, got %T", k, field)
		}
		for _, s := range lst {
			if _, ok := s.(string); !ok {
				return fmt.Errorf("%q should be a string, got %T", s, s)
			}
		}

	}
	return nil
}

func normalizeID(rn runner.Runner, t, id string) (string, error) {
	var err error
	nid := id
	// For projects, the ID in the state is the project ID, but we need project number in policies.
	if t == "project" {
		if nid, err = projectNumber(rn, id); err != nil {
			return "", err
		}
	} else if t == "folder" {
		// For folders, the ID can be either {folder_id} or folders/{folder_id}. Remove the 'folders/' prefix if exists.
		nid = strings.TrimPrefix(id, "folders/")
	}
	return nid, nil
}

func projectNumber(rn runner.Runner, id string) (string, error) {
	cmd := exec.Command("gcloud", "projects", "describe", id, "--format", "json")
	out, err := rn.CmdOutput(cmd)
	if err != nil {
		return "", fmt.Errorf("failed to get project number for project %q: %v", id, err)
	}

	var p struct {
		ProjectNumber string `json:"projectNumber"`
	}

	if err := json.Unmarshal(out, &p); err != nil {
		return "", fmt.Errorf("failed to parse project number from gcloud output: %v", err)
	}

	if p.ProjectNumber == "" {
		return "", fmt.Errorf("project number is empty")
	}

	return p.ProjectNumber, nil
}
