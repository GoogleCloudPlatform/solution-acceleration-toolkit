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

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/zclconf/go-cty/cty"
	ctyjson "github.com/zclconf/go-cty/cty/json"
)

// Config is the user supplied config for the engine.
type Config struct {
	// TODO(https://github.com/hashicorp/hcl/issues/291): Remove the need for DataCty.
	DataCty *cty.Value             `hcl:"data,optional" json:"-"`
	Data    map[string]interface{} `json:"data,omitempty"`

	Templates []*templateInfo `hcl:"templates,block" json:"templates,omitempty"`
}

type templateInfo struct {
	ComponentPath string                  `hcl:"component_path,optional" json:"component_path,omitempty"`
	RecipePath    string                  `hcl:"recipe_path,optional" json:"recipe_path,omitempty"`
	OutputPath    string                  `hcl:"output_path,optional" json:"output_path,omitempty"`
	Flatten       []*template.FlattenInfo `hcl:"flatten,block" json:"flatten,omitempty"`

	DataCty *cty.Value             `hcl:"data,optional" json:"-"`
	Data    map[string]interface{} `json:"data,omitempty"`
}

func (c *Config) Init() error {
	var err error
	if c.DataCty != nil {
		c.Data, err = ctyValueToMap(c.DataCty)
		if err != nil {
			return fmt.Errorf("failed to convert %v to map: %v", c.DataCty, err)
		}
	}

	for _, t := range c.Templates {
		if t.DataCty != nil {
			t.Data, err = ctyValueToMap(t.DataCty)
			if err != nil {
				return fmt.Errorf("failed to convert %v to map: %v", t.DataCty, err)
			}
		}
	}
	return nil
}

func ctyValueToMap(value *cty.Value) (map[string]interface{}, error) {
	b, err := ctyjson.Marshal(*value, cty.DynamicPseudoType)
	if err != nil {
		return nil, err
	}

	type jsonRepr struct {
		Value map[string]interface{}
	}

	var jr jsonRepr
	if err := json.Unmarshal(b, &jr); err != nil {
		return nil, err
	}

	return jr.Value, nil
}
