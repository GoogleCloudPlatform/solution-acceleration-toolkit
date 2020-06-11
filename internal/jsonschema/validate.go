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

// Package jsonschema defines helpers for JSON schema validation.
package jsonschema

import (
	"errors"
	"fmt"
	"strings"

	"github.com/xeipuuv/gojsonschema"
)

// ValidateMap validates the given config map against the given schema map.
func ValidateMap(schema, conf map[string]interface{}) error {
	return validate(gojsonschema.NewGoLoader(schema), gojsonschema.NewGoLoader(conf))
}

// Validate validates the given config JSON against hte given schema JSON.
func ValidateJSONBytes(schema, conf []byte) error {
	return validate(gojsonschema.NewBytesLoader(schema), gojsonschema.NewBytesLoader(conf))
}

func validate(schema, conf gojsonschema.JSONLoader) error {
	result, err := gojsonschema.Validate(schema, conf)
	if err != nil {
		return fmt.Errorf("validate config: %v", err)
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
