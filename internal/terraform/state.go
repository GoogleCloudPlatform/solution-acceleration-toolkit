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

// Package terraform provides definitions of Terraform resources in JSON format.
// This intentially does not define all fields in the plan JSON.
// https://www.terraform.io/docs/internals/json-format.html#plan-representation
package terraform

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/hashicorp/terraform/states"
	"github.com/hashicorp/terraform/states/statefile"
)

func ResourcesFromState(path string) ([]*states.Resource, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	stateFile, err := statefile.Read(f)
	if err != nil {
		return nil, err
	}

	var resources []*states.Resource
	for _, m := range stateFile.State.Modules {
		for _, r := range m.Resources {
			resources = append(resources, r)
		}
	}

	return resources, nil
}

func GetInstancesForType(resources []*states.Resource, kind string) ([]map[string]interface{}, error) {
	var instances []map[string]interface{}
	for _, r := range resources {
		if r.Addr.Type == kind {
			for _, i := range r.Instances {
				var instance map[string]interface{}
				if err := json.Unmarshal(i.Current.AttrsJSON, &instance); err != nil {
					return nil, fmt.Errorf("unmarshal json: %v", err)
				}
				instances = append(instances, instance)
			}
		}
	}
	return instances, nil
}
