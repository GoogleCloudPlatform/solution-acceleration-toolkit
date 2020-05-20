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
)

var configs = []ProviderConfigMap{
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
		cvs []ProviderConfigMap
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

func TestUserChoice(t *testing.T) {
	choices := []string{"ch1", "ch2", "ch3", "ch4"}
	tests := []struct {
		input string
		want  string
	}{
		// Empty imput is skip.
		{"\n", ""},

		// Invalid inputs.
		{"a\n1\n", "ch2"},

		// Invalid choices.
		{"15\n-1\n1\n", "ch2"},

		// Boundary - first choice.
		{"0\n", "ch1"},

		// Boundary - last choice.
		{"3\n", "ch4"},

		// Stripping spaces.
		{"  0 \n", "ch1"},

		// Only select the first choice, ignore further input.
		{"0\n1\n2\n", "ch1"},
	}

	for _, tc := range tests {
		// Temporarily redirect output to null while running
		stdout := os.Stdout
		os.Stdout = os.NewFile(0, os.DevNull)

		out, err := userChoice(strings.NewReader(tc.input), choices)

		// Restore.
		os.Stdout = stdout

		if err != nil {
			t.Fatalf("userChoice(%q) failed: %v", tc.input, err)
		}
		if out != tc.want {
			t.Errorf("userChoice(%q) = %v; want %v", tc.input, out, tc.want)
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
		got, err := imp.ImportID(resourceChange, configs[0])
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
		if got, err := imp.ImportID(resourceChange, configs[0]); err == nil {
			t.Errorf("%v ImportID(%v, %v) succeeded for malformed input, want error; got = %v", imp, resourceChange, configs, got)
		}
	}
}
