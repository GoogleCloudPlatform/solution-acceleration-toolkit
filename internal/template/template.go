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

// Package template provides utility functions around reading and writing templates.
package template

import (
	"bytes"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"text/template"

	"github.com/imdario/mergo"
)

var mergoOpts = []func(*mergo.Config){
	mergo.WithOverride,
	mergo.WithOverwriteWithEmptyValue,
	mergo.WithAppendSlice,
}

// FlattenInfo describes keys to flatten. If index is not a nil pointer then it is assumed the
// value is a list that must be flattened at the specific index.
type FlattenInfo struct {
	Key   string `hcl:"key,attr" json:"key"`
	Index *int   `hcl:"index,optional" json:"index,omitempty"`
}

// WriteDir generates files to directory `outputDir` based on templates from directory `inputDir` and `data`.
func WriteDir(inputDir, outputDir string, data map[string]interface{}) error {
	fs, err := ioutil.ReadDir(inputDir)
	if err != nil {
		return fmt.Errorf("read dir %q: %v", inputDir, err)
	}
	if len(fs) == 0 {
		return fmt.Errorf("found no files in %q to write", inputDir)
	}

	for _, f := range fs {
		in := filepath.Join(inputDir, f.Name())
		out := filepath.Join(outputDir, f.Name())

		if f.IsDir() {
			if err := WriteDir(in, out, data); err != nil {
				return err
			}
			continue
		}

		if err := WriteFile(in, out, data); err != nil {
			return err
		}
	}
	return nil
}

// WriteFile generates `out` based on the `in` template and `data`.
func WriteFile(in, out string, data map[string]interface{}) error {
	if err := os.MkdirAll(filepath.Dir(out), 0755); err != nil {
		return fmt.Errorf("mkdir %q: %v", filepath.Dir(out), err)
	}

	b, err := ioutil.ReadFile(in)
	if err != nil {
		return fmt.Errorf("read %q: %v", in, err)
	}

	tmpl, err := template.New(in).Funcs(funcMap).Option("missingkey=error").Parse(string(b))
	if err != nil {
		return fmt.Errorf("parse template %q: %v", in, err)
	}

	outFile, err := os.OpenFile(out, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer outFile.Close()

	if err := tmpl.Execute(outFile, data); err != nil {
		return fmt.Errorf("execute template %q: %v", in, err)
	}
	return nil
}

// WriteBuffer creates a buffer with template `text` filled with values from `data`.
func WriteBuffer(text string, data map[string]interface{}) (*bytes.Buffer, error) {
	var buf bytes.Buffer
	tmpl, err := template.New("").Funcs(funcMap).Option("missingkey=error").Parse(text)
	if err != nil {
		return nil, err
	}
	if err := tmpl.Execute(&buf, data); err != nil {
		return nil, fmt.Errorf("execute buffer %s with data %v: %v", text, data, err)
	}
	return &buf, nil
}

// MergeData merges template data from src to dst.
// For all keys in flatten it will pop the key and merge back into dst.
func MergeData(dst map[string]interface{}, src map[string]interface{}) error {
	if dst == nil {
		return errors.New("dst must not be nil")
	}
	return mergo.Merge(&dst, src, mergoOpts...)
}

// FlattenData returns the map of kes from src flattened into a single map.
func FlattenData(src map[string]interface{}, fis []*FlattenInfo) (map[string]interface{}, error) {
	res := make(map[string]interface{})
	for _, fi := range fis {
		v := get(src, fi.Key)
		if v == nil {
			return nil, fmt.Errorf("flatten key %q not found in data: %v", fi.Key, src)
		}
		// TODO(umairidris): Support deleting multi level key
		delete(src, fi.Key)

		// If index is set assume value is a list and the index is being flattened.
		if i := fi.Index; i != nil {
			vs := v.([]interface{})
			if *i >= len(vs) {
				return nil, fmt.Errorf("flatten index for key %q out of range: got %v, want value between 0 and %v", fi.Key, fi.Index, len(vs))
			}
			v = vs[*i]
		}

		m, ok := v.(map[string]interface{})
		if !ok {
			return nil, fmt.Errorf("flatten key %q is not a map, got type %T, value %v", fi.Key, v, v)
		}
		if err := MergeData(res, m); err != nil {
			return nil, err
		}
	}
	return res, nil
}
