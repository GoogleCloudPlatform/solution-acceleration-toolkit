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

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/jsonschema"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/ghodss/yaml"
	"github.com/hashicorp/hcl/v2/hclsimple"
	"github.com/zclconf/go-cty/cty"
)

// Config is the user supplied config for the engine.
// HCL struct tags are documented at https://pkg.go.dev/github.com/hashicorp/hcl2/gohcl.
type Config struct {
	// HCL decoder can't unmarshal into map[string]interface{},
	// so make it unmarshal to a cty.Value and manually convert to map.
	// TODO(https://github.com/hashicorp/hcl/issues/291): Remove the need for DataCty.
	DataCty *cty.Value             `hcl:"data,optional" json:"-"`
	Data    map[string]interface{} `json:"data,omitempty"`

	SchemaCty *cty.Value             `hcl:"schema,optional" json:"-"`
	Schema    map[string]interface{} `json:"schema,omitempty"`

	Templates []*templateInfo `hcl:"template,block" json:"template,omitempty"`
}

type templateInfo struct {
	Name          string                  `hcl:",label" json:"name"`
	Source        string                  `hcl:"source,optional" json:"source,omitempty"`
	ComponentPath string                  `hcl:"component_path,optional" json:"component_path,omitempty"`
	RecipePath    string                  `hcl:"recipe_path,optional" json:"recipe_path,omitempty"`
	OutputPath    string                  `hcl:"output_path,optional" json:"output_path,omitempty"`
	Flatten       []*template.FlattenInfo `hcl:"flatten,block" json:"flatten,omitempty"`

	DataCty *cty.Value             `hcl:"data,optional" json:"-"`
	Data    map[string]interface{} `json:"data,omitempty"`
}

// Init initializes and validates the config.
func (c *Config) Init() error {
	var err error
	if c.DataCty != nil {
		c.Data, err = hcl.CtyValueToMap(c.DataCty)
		if err != nil {
			return fmt.Errorf("failed to convert %v to map: %v", c.DataCty, err)
		}
	}

	if c.Data == nil {
		c.Data = make(map[string]interface{})
	}

	if c.SchemaCty != nil {
		c.Schema, err = hcl.CtyValueToMap(c.SchemaCty)
		if err != nil {
			return fmt.Errorf("failed to convert schema %v to map: %v", c.SchemaCty, err)
		}
		// Add output_path to be a valid field in schema. It is set for each template below.
		props := c.Schema["properties"].(map[string]interface{})
		props["output_path"] = make(map[string]interface{})
	}

	for _, t := range c.Templates {
		if t.DataCty != nil {
			t.Data, err = hcl.CtyValueToMap(t.DataCty)
			if err != nil {
				return fmt.Errorf("failed to convert data %v to map: %v", t.DataCty, err)
			}
		}
		if t.Data == nil {
			t.Data = make(map[string]interface{})
		}
		if t.OutputPath != "" {
			t.Data["output_path"] = filepath.Clean(t.OutputPath)
		}
	}
	return c.validate()
}

func (c *Config) validate() error {
	sj, err := hcl.ToJSON([]byte(schema))
	if err != nil {
		return err
	}
	cj, err := json.Marshal(c)
	if err != nil {
		return err
	}

	return jsonschema.ValidateJSONBytes(sj, cj)
}

func loadConfig(path string, data map[string]interface{}) (*Config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	buf, err := template.WriteBuffer(string(b), data)
	if err != nil {
		return nil, err
	}

	// Convert yaml to json so hcl decoder can parse it.
	cj := buf.Bytes()
	if filepath.Ext(path) == ".yaml" {
		cj, err = yaml.YAMLToJSON(cj)
		if err != nil {
			return nil, err
		}
		// hclsimple.Decode doesn't actually use the path for anything other
		// than its extension, so just pass in any file name ending with json so
		// the library knows to treat these bytes as json and not yaml.
		path = "file.json"
	}

	c := new(Config)
	if err := hclsimple.Decode(path, cj, nil, c); err != nil {
		return nil, err
	}
	if err := c.Init(); err != nil {
		return nil, err
	}
	return c, nil
}
