// Copyright 2020 Google LLC.
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

package template

import (
	"fmt"
	"strings"

	"github.com/rodaine/hclencoder"
)

var funcMap = map[string]interface{}{
	"get":          get,
	"has":          has,
	"hcl":          hcl,
	"hclField":     hclField,
	"resourceName": resourceName,
}

// get allows a template to optionally lookup a value from a dict.
// If a value is not found, it will check for a single default.
// If there is no default, it will return nil.
// There should be at most one default value set.
//
// Keys can reference multiple levels of maps by using "." to indicate a new level
// (e.g. L1.L2 will lookup key L1 in the top level map then L2 within the value.)
func get(m map[string]interface{}, key string, def ...interface{}) interface{} {
	split := strings.Split(key, ".")
	for i, k := range split {
		v, ok := m[k]
		switch {
		case !ok:
			if len(def) == 1 {
				return def[0]
			}
			return nil
		case i == len(split)-1:
			return v
		default:
			m = v.(map[string]interface{})
		}
	}
	return nil
}

// has determines whether the key is found in the given map.
// Keys can reference multiple levels of maps by using "." to indicate a new level
// (e.g. L1.L2 will lookup key L1 in the top level map then L2 within the value.)
func has(m map[string]interface{}, key string) bool {
	return get(m, key) != nil
}

// hcl marshals the given value to HCL.
func hcl(v interface{}) (string, error) {
	b, err := hclencoder.Encode(v)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// hclField returns a hcl marshaled field e.g. `name = "foo"`
func hclField(m map[string]interface{}, key string, req bool) (string, error) {
	v, ok := m[key]
	switch {
	case ok:
		b, err := hclencoder.Encode(v)
		if err != nil {
			return "", err
		}
		return fmt.Sprintf("%s = %s", key, string(b)), nil
	case req:
		return "", fmt.Errorf("required field missing: %v", key)
	default:
		return "", nil
	}
}

// resourceName builds a Terraform resource name.
// GCP resource names often use "-" but Terraform resource names should use "_".
// The resource name is fetched from the given map and key.
// To override the default behaviour, a user can set the key 'resource_name' in
// given map, which will be given precedence.
func resourceName(m map[string]interface{}, key string) (string, error) {
	v, ok := m["resource_name"]
	if !ok {
		v, ok = m[key]
		if !ok {
			return "", fmt.Errorf("map did not contain key \"resource_name\" nor %q", k)
		}
	}

	name, ok := v.(string)
	if !ok {
		return "", fmt.Errorf("resource name value %v is not a string", v)
	}
	return strings.Replace(name, "-", "_", -1), nil
}
