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
	"testing"
)

const testStatePath = "testdata/test.tfstate"

func TestResourcesFromStateFile(t *testing.T) {
	resources, err := ResourcesFromStateFile(testStatePath)
	if err != nil {
		t.Fatalf("read resources from state: %v", err)
	}

	wantResourceCount := 9
	if len(resources) != wantResourceCount {
		t.Fatalf("retrieved number of resources differ: got %d, want %d", len(resources), wantResourceCount)
	}
}

func TestGetInstancesForType(t *testing.T) {
	resources, err := ResourcesFromStateFile(testStatePath)
	if err != nil {
		t.Fatalf("read resources from state: %v", err)
	}

	tests := []struct {
		kind      string
		wantCount int
	}{
		{"google_organization_iam_member", 10},
		{"google_folder_iam_member", 0},
		{"google_project_iam_member", 5},
	}

	for _, tc := range tests {
		instances, err := GetInstancesForType(resources, tc.kind)
		if err != nil {
			t.Fatalf("GetInstancesForType: %v", err)
		}

		if len(instances) != tc.wantCount {
			t.Errorf("retrieved number of resource instances differ for type %q: got %d, want %d", tc.kind, len(instances), tc.wantCount)
		}
	}

}
