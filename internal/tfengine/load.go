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

package tfengine

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/jsonschema"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/ghodss/yaml"
	"github.com/hashicorp/hcl/v2/hclsimple"
)

func loadConfig(path string, data map[string]interface{}) (*Config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	buf, err := template.WriteBuffer(string(b), data)
	if err != nil {
		return nil, err
	}

	// TODO(https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/issues/86): deprecate yaml.
	cj := buf.Bytes()
	if filepath.Ext(path) == ".yaml" {
		cj, err = yaml.YAMLToJSON(cj)
		if err != nil {
			return nil, err
		}
		path = "file.json"
	}

	c := new(Config)
	if err := hclsimple.Decode(path, cj, nil, c); err != nil {
		return nil, err
	}
	if err := c.Init(); err != nil {
		return nil, err
	}
	if err := validate(c); err != nil {
		return nil, err
	}
	return c, nil
}

func validate(c *Config) error {
	sj, err := yaml.YAMLToJSON([]byte(schema))
	if err != nil {
		return fmt.Errorf("convert schema to JSON: %v", err)
	}

	cj, err := json.Marshal(c)
	if err != nil {
		return err
	}

	return jsonschema.Validate(sj, cj)
}
