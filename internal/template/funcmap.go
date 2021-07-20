// Copyright 2021 Google LLC.
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
	"regexp"
	"strings"
	"time"

	"github.com/rodaine/hclencoder"
)

var funcMap = map[string]interface{}{
	"get":               get,
	"has":               has,
	"hcl":               hcl,
	"hclField":          hclField,
	"merge":             merge,
	"replace":           replace,
	"resourceName":      resourceName,
	"now":               time.Now,
	"trimSpace":         strings.TrimSpace,
	"regexReplaceAll":   regexReplaceAll,
	"makeSlice":         makeSlice,
	"schemaDescription": schemaDescription,
}

// invalidIDRE defines the invalid characters not allowed in terraform resource names.
var invalidIDRE = regexp.MustCompile("[^a-z0-9_]")

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
	return strings.TrimSpace(string(b)), nil
}

// hclField returns a hcl marshaled field e.g. `name = "foo"`, if present.
// For required fields, use the hcl func.
func hclField(m map[string]interface{}, key string) (string, error) {
	v, ok := m[key]
	if !ok {
		return "", nil
	}
	b, err := hclencoder.Encode(v)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%s = %s", key, string(b)), nil
}

func merge(srcs ...map[string]interface{}) (interface{}, error) {
	dst := make(map[string]interface{})
	for _, src := range srcs {
		if err := MergeData(dst, src); err != nil {
			return nil, err
		}
	}
	return dst, nil
}

// resourceName builds a Terraform resource name.
// Invalid characters that are not allowed in terraform resource names such as
// "-", ".", and "@" are replaced with "_".
// The resource name is fetched from the given map and key.
// To override the default behaviour, a user can set the key 'resource_name' in
// given map, which will be given precedence.
func resourceName(m map[string]interface{}, key string) (string, error) {
	v, ok := m["resource_name"]
	if !ok {
		v, ok = m[key]
		if !ok {
			return "", fmt.Errorf("map did not contain key \"resource_name\" nor %q", key)
		}
	}

	name, ok := v.(string)
	if !ok {
		return "", fmt.Errorf("resource name value %v is not a string", v)
	}
	return invalidIDRE.ReplaceAllString(strings.ToLower(name), "_"), nil
}

// alias for strings.Replace with the number of characters fixed to -1 (all).
func replace(s, old, new string) string {
	return strings.Replace(s, old, new, -1)
}

func regexReplaceAll(regex string, s string, repl string) (string, error) {
	r, err := regexp.Compile(regex)
	if err != nil {
		return "", err
	}
	return r.ReplaceAllString(s, repl), nil
}

// makeSlice combines the arguments into an array and returns the array.
func makeSlice(args ...interface{}) []interface{} {
	return args
}

// schemaDescription returns a heredoc or single line string
// according to the description provided format.
func schemaDescription(s string) string {
	if strings.Contains(s, "\n") {
		return fmt.Sprintf("<<EOF\n%s\nEOF", s)
	}

	return fmt.Sprintf(`"%s"`, s)
}
