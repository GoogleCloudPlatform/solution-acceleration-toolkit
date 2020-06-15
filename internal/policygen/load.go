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
	"io/ioutil"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/jsonschema"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/ghodss/yaml"
	"github.com/hashicorp/terraform/states"
	"github.com/zclconf/go-cty/cty"
)

// config is the struct representing the Policy Generator configuration.
type config struct {
	TemplateDir     string                 `json:"template_dir"`
	ForsetiPolicies map[string]interface{} `json:"forseti_policies"`
	GCPOrgPolicies  map[string]interface{} `json:"gcp_org_policies"`

	SchemaCty *cty.Value             `hcl:"schema,optional" json:"-"`
	Schema    map[string]interface{} `json:"schema,omitempty"`
}

func ValidateOrgPoliciesConfig(conf map[string]interface{}, allowAdditionalProperties bool) error {
	s := orgPoliciesSchema
	if !allowAdditionalProperties {
		s = append(s, []byte("additionalProperties = false")...)
	}

	sj, err := hcl.ToJSON(s)
	if err != nil {
		return err
	}
	cj, err := json.Marshal(conf)
	if err != nil {
		return err
	}

	return jsonschema.ValidateJSONBytes(sj, cj)
}

func loadConfig(path string) (*config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config %q: %v", path, err)
	}

	cj, err := yaml.YAMLToJSON(b)
	if err != nil {
		return nil, fmt.Errorf("convert config to JSON: %v", err)
	}

	sj, err := hcl.ToJSON(schema)
	if err != nil {
		return nil, fmt.Errorf("convert schema to JSON: %v", err)
	}

	if err := jsonschema.ValidateJSONBytes(sj, cj); err != nil {
		return nil, err
	}

	c := new(config)
	if err := yaml.Unmarshal(cj, c); err != nil {
		return nil, fmt.Errorf("unmarshal config %q: %v", path, err)
	}

	if c.GCPOrgPolicies != nil {
		if err := ValidateOrgPoliciesConfig(c.GCPOrgPolicies, false); err != nil {
			return nil, err
		}
	}

	if !filepath.IsAbs(c.TemplateDir) {
		c.TemplateDir = filepath.Join(filepath.Dir(path), c.TemplateDir)
	}
	return c, nil
}

func loadResources(path string) ([]*states.Resource, error) {
	path, err := pathutil.Expand(path)
	if err != nil {
		return nil, fmt.Errorf("normalize path %q: %v", path, err)
	}

	resources, err := terraform.ResourcesFromState(path)
	if err != nil {
		return nil, fmt.Errorf("read resources from Terraform state file %q: %v", path, err)
	}

	return resources, nil
}
