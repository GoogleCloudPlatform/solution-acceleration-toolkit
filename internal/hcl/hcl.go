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

package hcl

import (
	"encoding/json"
	"fmt"
	"os/exec"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/hashicorp/hcl/v2/hclsimple"
	"github.com/zclconf/go-cty/cty"
	ctyjson "github.com/zclconf/go-cty/cty/json"
)

// FormatDir formats the hcl files in the given directory.
// The user must have the terraform binary in their PATH.
func FormatDir(rn runner.Runner, dir string) error {
	tfFmt := exec.Command("terraform", "fmt", "-recursive")
	tfFmt.Dir = dir
	// Silence stdout.
	if _, err := rn.CmdOutput(tfFmt); err != nil {
		return fmt.Errorf("format terraform files: %v", err)
	}
	return nil
}

// ToJSON converts input bytes in HCL format to output bytes in JSON format.
func ToJSON(b []byte) ([]byte, error) {
	// Directly trying to unmarshal to cty.Value doesn't seem to work,
	// so wrap in a dummy field.
	var wrap struct {
		Value *cty.Value `hcl:"value"`
	}
	b = []byte(fmt.Sprintf("value = {\n%v\n}", string(b)))

	if err := hclsimple.Decode("file.hcl", []byte(b), nil, &wrap); err != nil {
		return nil, fmt.Errorf("convert HCL to JSON: %v", err)
	}

	m, err := CtyValueToMap(wrap.Value)
	if err != nil {
		return nil, err
	}
	return json.Marshal(m)
}

// CtyValueToMap converts a cty.Value to a map.
// HCL decoder can't unmarshal into map[string]interface{}, so make it unmarshal to a cty.Value and manually convert to map.
func CtyValueToMap(value *cty.Value) (map[string]interface{}, error) {
	b, err := ctyjson.Marshal(*value, cty.DynamicPseudoType)
	if err != nil {
		return nil, err
	}

	var jr struct {
		Value map[string]interface{}
	}

	if err := json.Unmarshal(b, &jr); err != nil {
		return nil, err
	}

	return jr.Value, nil
}
