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
	"errors"
	"fmt"
	"io/ioutil"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/ghodss/yaml"
	"github.com/xeipuuv/gojsonschema"
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

	cj, err := yaml.YAMLToJSON(buf.Bytes())
	if err != nil {
		return nil, err
	}

	if err := validate(cj); err != nil {
		return nil, err
	}

	c := new(Config)
	if err := json.Unmarshal(cj, c); err != nil {
		return nil, err
	}
	return c, nil
}

func validate(confJSON []byte) error {
	schemaJSON, err := yaml.YAMLToJSON([]byte(schema))
	if err != nil {
		return fmt.Errorf("failed to load schema: %v", err)
	}

	result, err := gojsonschema.Validate(gojsonschema.NewBytesLoader(schemaJSON), gojsonschema.NewBytesLoader(confJSON))
	if err != nil {
		return fmt.Errorf("failed to validate config: %v", err)
	}

	if len(result.Errors()) == 0 {
		return nil
	}

	var sb strings.Builder
	sb.WriteString("config has validation errors:")
	for _, err := range result.Errors() {
		sb.WriteString(fmt.Sprintf("\n- %s: %s", err.Context().String(), err.Description()))
	}
	return errors.New(sb.String())

}
