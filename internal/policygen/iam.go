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
	"fmt"
	"log"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/hashicorp/terraform/states"
)

type binding struct {
	Type   string
	ID     string
	Role   string
	Member string
}

func generateIAMBindingsPolicies(resources []*states.Resource, outputDir string) error {

	bindings, err := bindings(resources)
	if err != nil {
		return err
	}
	log.Printf("Found %d bindings from input Terraform resources", len(bindings))
	// TODO(xingao): Support google_*_iam_bindings.
	// TODO(xingao): Generate policies.

	return nil
}

func bindings(resources []*states.Resource) ([]*binding, error) {
	var bindings []*binding
	instances, err := terraform.GetInstancesForType(resources, "google_project_iam_member")
	if err != nil {
		return nil, fmt.Errorf("get resource instances for type %q: %v", "google_project_iam_member", err)
	}

	for _, i := range instances {
		if err := validate(i, []string{"project", "role", "member"}); err != nil {
			return nil, err
		}

		bindings = append(bindings, &binding{
			Type:   "project",
			ID:     i["project"].(string), // Type checked in validate()
			Role:   i["role"].(string),
			Member: i["member"].(string),
		})
	}

	instances, err = terraform.GetInstancesForType(resources, "google_folder_iam_member")
	if err != nil {
		return nil, fmt.Errorf("get resource instances for type %q: %v", "google_folder_iam_member", err)
	}

	for _, i := range instances {
		if err := validate(i, []string{"folder", "role", "member"}); err != nil {
			return nil, err
		}

		bindings = append(bindings, &binding{
			Type:   "folder",
			ID:     i["folder"].(string), // Type checked in validate()
			Role:   i["role"].(string),
			Member: i["member"].(string),
		})
	}

	instances, err = terraform.GetInstancesForType(resources, "google_organization_iam_member")
	if err != nil {
		return nil, fmt.Errorf("get resource instances for type %q: %v", "google_organization_iam_member", err)
	}

	for _, i := range instances {
		if err := validate(i, []string{"org_id", "role", "member"}); err != nil {
			return nil, err
		}

		bindings = append(bindings, &binding{
			Type:   "organization",
			ID:     i["org_id"].(string), // Type checked in validate()
			Role:   i["role"].(string),
			Member: i["member"].(string),
		})
	}
	return bindings, nil
}

// validate checks the presense of mandatory fields and assert string type.
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
