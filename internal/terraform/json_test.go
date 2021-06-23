// Copyright 2021 Google LLC
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

package terraform

import (
	"encoding/json"
	"io/ioutil"
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
)

const testPlanPath = "testdata/plan.json"

// These functions will fatal out so there's no need to return errors.
func readTestFile(t *testing.T, path string) []byte {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		t.Fatalf("read plan json file: %v", err)
	}
	return b
}

func unmarshalTestPlan(t *testing.T) *plan {
	b := readTestFile(t, testPlanPath)

	p := new(plan)
	if err := json.Unmarshal(b, p); err != nil {
		t.Fatalf("unmarshal json: %v", err)
	}
	return p
}

func TestReadPlanChanges(t *testing.T) {
	b := readTestFile(t, testPlanPath)

	// Predefine the changes in the testdata file.
	addBucketChange := ResourceChange{
		Address: "google_storage_bucket.gcs_tf_bucket",
		Mode:    "managed",
		Kind:    "google_storage_bucket",
		Name:    "gcs_tf_bucket",
	}
	recreateAPIChange := ResourceChange{
		Address: "google_project_service.enable_container_registry",
		Mode:    "managed",
		Kind:    "google_project_service",
		Name:    "enable_container_registry",
	}

	tests := []struct {
		actions []string
		want    []ResourceChange
	}{
		// No actions - should get all changes.
		{[]string{}, []ResourceChange{addBucketChange, recreateAPIChange}},

		// Only one action - should get only that change.
		{[]string{"create"}, []ResourceChange{addBucketChange}},

		// Two actions - should get only the one with both actions in that order.
		{[]string{"delete", "create"}, []ResourceChange{recreateAPIChange}},

		// Two actions in a different order - should return nothing.
		{[]string{"create", "delete"}, []ResourceChange{}},
	}

	for _, tc := range tests {
		changes, err := ReadPlanChanges(b, tc.actions)
		if err != nil {
			t.Fatalf("unmarshal json: %v", err)
		}
		if diff := cmp.Diff(tc.want, changes, cmpopts.IgnoreFields(ResourceChange{}, "Change"), cmpopts.EquateEmpty()); diff != "" {
			t.Errorf("ReadPlanChanges(%v, %v) returned diff (-want +got):\n%s", testPlanPath, tc.actions, diff)
		}
	}
}

func TestResourceProviderConfig(t *testing.T) {
	p := unmarshalTestPlan(t)

	tests := []struct {
		kind string
		name string
	}{
		// Empty address - should return empty.
		{"", ""},

		// No provider for this resource - should return empty.
		{"google_storage_bucket", "some_other_bucket"},

		// Provider config exists - should not return empty.
		{"google_storage_bucket", "gcs_tf_bucket"},
	}

	expectedProviderConfig := ProviderConfig{
		Name:              "google",
		VersionConstraint: "3.5.0",
		Alias:             "myprovider",
		Expressions: expressions{
			"credentials": map[string]interface{}{},
			"location":    map[string]interface{}{"constant_value": "US"},
			"project":     map[string]interface{}{"references": []interface{}{"var.project"}},
			"region":      map[string]interface{}{"references": []interface{}{"var.region"}},
			"zone":        map[string]interface{}{"references": []interface{}{"var.zone"}},
		},
	}
	for _, tc := range tests {
		config, ok := resourceProviderConfig(tc.kind, tc.name, p)

		want := ProviderConfig{}
		if ok {
			want = expectedProviderConfig
		}

		if diff := cmp.Diff(want, config, cmpopts.EquateEmpty()); diff != "" {
			t.Errorf("resourceProviderConfig(%q, %q, %v) returned diff (-want +got):\n%s", tc.kind, tc.name, testPlanPath, diff)
		}
	}
}

func TestResolveReference(t *testing.T) {
	p := unmarshalTestPlan(t)

	tests := []struct {
		ref  string
		want interface{}
	}{
		// Empty reference - should return nil.
		{"", nil},

		// Nonexistent variable - should return nil.
		{"var.nonexistent", nil},

		// Existing variable - should return variable value.
		{"var.bucket_name", "test-bucket"},

		// No other reference types are supported at the moment.
	}
	for _, tc := range tests {
		resolved := resolveReference(tc.ref, p)
		if !cmp.Equal(resolved, tc.want) {
			t.Errorf("resolveReference(%q, %v) = %v; want %v", tc.ref, testPlanPath, resolved, tc.want)
		}
	}
}

func TestResolveExpression(t *testing.T) {
	p := unmarshalTestPlan(t)

	emptyExpr := map[string]interface{}{}
	constantValue := "US"
	nonexistentRef := map[string]interface{}{
		"references": []interface{}{"nonexistent"},
	}

	tests := []struct {
		expr map[string]interface{}
		want interface{}
	}{
		// nil expression - should return nil.
		{nil, nil},

		// Empty expression - should return it as-is.
		{emptyExpr, emptyExpr},

		// constant_value - should return value directly.
		{
			map[string]interface{}{
				"constant_value": constantValue,
			},
			constantValue,
		},

		// references with nonexistent reference - should return as-is.
		{nonexistentRef, nonexistentRef},

		// references with one reference - should resolve.
		{
			map[string]interface{}{
				"references": []interface{}{
					"var.bucket_name",
				},
			},
			"test-bucket",
		},

		// references with multiple references - should resolve first one that matches.
		{
			map[string]interface{}{
				"references": []interface{}{
					"nonexistent",
					"anothernontexistent",
					"var.project",
					"var.bucket_name",
				},
			},
			"test-project",
		},
	}
	for _, tc := range tests {
		resolved := resolveExpression(tc.expr, p)
		if diff := cmp.Diff(tc.want, resolved); diff != "" {
			t.Errorf("resolveExpression(%q, %v) returned diff (-want +got):\n%s", tc.expr, testPlanPath, diff)
		}
	}
}

func TestReadProviderConfigValues(t *testing.T) {
	b := readTestFile(t, testPlanPath)

	kind := "google_storage_bucket"
	name := "gcs_tf_bucket"
	got, err := ReadProviderConfigValues(b, kind, name)
	if err != nil {
		t.Fatalf("ReadProviderConfigValues(%v, %q, %q) err: %v", testPlanPath, kind, name, err)
	}

	want := map[string]interface{}{
		"credentials": map[string]interface{}{},
		"location":    "US",
		"project":     "test-project",
		"region":      "us-central1",
		"zone":        "us-central1-c",
	}

	if diff := cmp.Diff(want, got, cmpopts.EquateEmpty()); diff != "" {
		t.Fatalf("retrieved provider configs differ (-want +got):\n%v", diff)
	}
}
