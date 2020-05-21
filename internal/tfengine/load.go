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
	"io/ioutil"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
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

	// tmp, err := ioutil.TempFile("", fmt.Sprintf("*.%s", filepath.Ext(path)))
	// if err != nil {
	// 	return nil, err
	// }

	// cj, err := yaml.YAMLToJSON(buf.Bytes())
	// if err != nil {
	// 	return nil, fmt.Errorf("convert config to JSON: %v", err)
	// }

	// sj, err := yaml.YAMLToJSON([]byte(schema))
	// if err != nil {
	// 	return nil, fmt.Errorf("convert schema to JSON: %v", err)
	// }

	// if err := jsonschema.Validate(sj, cj); err != nil {
	// 	return nil, err
	// }

	c := new(Config)
	if err := hclsimple.Decode(path, buf.Bytes(), nil, c); err != nil {
		return nil, err
	}
	// if err := json.Unmarshal(cj, c); err != nil {
	// 	return nil, err
	// }
	if err := c.Init(); err != nil {
		return nil, err
	}
	return c, nil
}
