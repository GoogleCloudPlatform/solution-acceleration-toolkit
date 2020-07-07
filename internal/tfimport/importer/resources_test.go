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

package importer

import (
	"os"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
)

var configs = []ConfigMap{
	{
		"":       "emptyValFirst",
		"mykey1": "key1First",
		"mykey2": "key2First",
	},
	nil, // nil map to ensure it doesn't crash the check.
	{},  // Empty map just to make sure it gets skipped correctly.
	{
		"mykey1": "key1Second",
		"mykey3": "key3Second",
	},
}

var resourceChange = terraform.ResourceChange{
	Change: terraform.Change{
		After: map[string]interface{}{
			"project": "myproject",
			"name":    "myresourcename",
		},
	},
}

func TestFromConfigValuesGot(t *testing.T) {
	tests := []struct {
		key  string
		want interface{}
	}{
		// Empty key - should still work.
		{"", "emptyValFirst"},

		// Key in second config - should return second one, not nil.
		{"mykey3", "key3Second"},

		// Key in both configs - should return first one.
		{"mykey1", "key1First"},
	}
	for _, tc := range tests {
		got, err := fromConfigValues(tc.key, configs...)
		if err != nil {
			t.Fatalf("fromConfigValues(%v, %v) failed: %v", tc.key, configs, err)
		}
		if got != tc.want {
			t.Errorf("fromConfigValues(%v, %v) = %v; want %v", tc.key, configs, got, tc.want)
		}
	}
}

func TestFromConfigValuesErr(t *testing.T) {
	tests := []struct {
		key string
		cvs []ConfigMap
	}{
		// Empty configs - should return err.
		{"", nil},

		// Key not in any config - should return err.
		{"nonExistentKey", configs},
	}
	for _, tc := range tests {
		if _, err := fromConfigValues(tc.key, tc.cvs...); err == nil {
			t.Errorf("fromConfigValues(%v, %v) succeeded for malformed input, want error", tc.key, tc.cvs)
		}
	}
}

func TestUserValue(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		// Empty.
		{"\n", ""},

		// Normal input.
		{"myinput\n", "myinput"},

		// Stripping spaces, but not in the middle.
		{"  my space   separated  input   \n", "my space   separated  input"},
	}

	for _, tc := range tests {
		// Temporarily redirect output to null while running
		stdout := os.Stdout
		os.Stdout = os.NewFile(0, os.DevNull)

		out, err := userValue(strings.NewReader(tc.input))

		// Restore.
		os.Stdout = stdout

		if err != nil {
			t.Fatalf("userValue(%q) failed: %v", tc.input, err)
		}
		if out != tc.want {
			t.Errorf("userValue(%q) = %v; want %v", tc.input, out, tc.want)
		}
	}
}

func TestSimpleImporter(t *testing.T) {
	tests := []struct {
		reqFields []string
		tmpl      string
		want      string
	}{
		// Empty.
		{[]string{}, "", ""},

		// Simple case, insert some template fields.
		{[]string{"project", "name"}, "projects/{{.project}}/resources/{{.name}}", "projects/myproject/resources/myresourcename"},
	}
	for _, tc := range tests {
		imp := &SimpleImporter{Fields: tc.reqFields, Tmpl: tc.tmpl}
		got, err := imp.ImportID(resourceChange, configs[0], false)
		if err != nil {
			t.Fatalf("%v ImportID(%v, %v) failed: %v", imp, resourceChange, configs, err)
		}
		if got != tc.want {
			t.Errorf("%v ImportID(%v, %v) = %v; want %v", imp, resourceChange, configs, got, tc.want)
		}
	}
}

func TestSimpleImporterErr(t *testing.T) {
	tests := []struct {
		reqFields []string
		tmpl      string
	}{
		// Field does not exist in configs.
		{[]string{"project", "name", "version"}, "projects/{{.project}}/secrets/{{.name}}/versions/{{.version}}"},

		// Template is using unknown field
		{[]string{"project", "name"}, "projects/{{.project}}/secrets/{{.name}}/versions/{{.version}}"},
	}
	for _, tc := range tests {
		imp := &SimpleImporter{Fields: tc.reqFields, Tmpl: tc.tmpl}
		if got, err := imp.ImportID(resourceChange, configs[0], false); err == nil {
			t.Errorf("%v ImportID(%v, %v) succeeded for malformed input, want error; got = %v", imp, resourceChange, configs, got)
		}
	}
}

func TestLoadFields(t *testing.T) {
	tests := []struct {
		fields []string
		want   map[string]interface{}
	}{
		// Empty.
		{[]string{}, map[string]interface{}{}},

		// Get some fields from both locations.
		{
			[]string{"", "name"},
			map[string]interface{}{
				"":     "emptyValFirst",
				"name": "myresourcename",
			},
		},
	}
	for _, tc := range tests {
		rc := resourceChange.Change.After
		got, err := loadFields(tc.fields, false, configs[0], rc)
		if err != nil {
			t.Fatalf("loadFields(%v, %v, %v, %v) failed: %v", tc.fields, false, configs[0], rc, err)
		}
		if !cmp.Equal(got, tc.want, cmpopts.EquateEmpty()) {
			t.Errorf("loadFields(%v, %v, %v, %v) = %v; want %v", tc.fields, false, configs[0], rc, got, tc.want)
		}
	}
}

func TestLoadFieldsErr(t *testing.T) {
	tests := []struct {
		fields      []string
		wantMissing []string
	}{
		// All fields missing.
		{[]string{"missing1", "missing2"}, []string{"missing1", "missing2"}},

		// Not all fields missing
		{[]string{"name", "missing2"}, []string{"missing2"}},
	}
	for _, tc := range tests {
		wantErr := &InsufficientInfoErr{MissingFields: tc.wantMissing}
		rc := resourceChange.Change.After
		_, err := loadFields(tc.fields, false, configs[0], rc)
		if diff := cmp.Diff(wantErr, err); diff != "" {
			t.Errorf("loadFields error differs (-want +got):\n%s", diff)
		}
	}
}
