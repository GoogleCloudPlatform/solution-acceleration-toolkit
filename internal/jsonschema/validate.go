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

func Validate(schemaJSON []byte, confJSON []byte) error {
	result, err := gojsonschema.Validate(gojsonschema.NewBytesLoader(schemaJSON), gojsonschema.NewBytesLoader(confJSON))
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
