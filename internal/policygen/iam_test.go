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

package policygen

import (
	"context"
	"sort"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestAllBindings(t *testing.T) {
	statePath := "testdata/subfolder/project.tfstate"
	resources, err := loadResources(context.Background(), statePath)
	if err != nil {
		t.Fatalf("loadResources(%q) = %v", statePath, err)
	}

	allBindings, err := allBindings(&Fake{}, resources)
	if err != nil {
		t.Fatalf("allBindings() = %v", err)
	}

	bindings := allBindings[root{Type: "project", ID: fakeProjectNumber}]

	wantBindings := roleBindings{
		// roles/owner in iam_bindings should replace the ones in iam_members.
		"roles/owner": []string{
			"group:real_owners_1@example.com",
			"group:real_owners_2@example.com",
			"group:real_owners_3@example.com",
		},
		"roles/editor": []string{
			"group:editors@example.com",
		},
		"roles/storage.objectViewer": []string{
			"serviceAccount:forseti-server-gcp-suffix@example-project.iam.gserviceaccount.com",
		},
	}

	for wantRole, wantMembers := range wantBindings {
		gotMembers, ok := bindings[wantRole]
		if !ok {
			t.Errorf("wanted role %q missing", wantRole)
		}
		sort.Strings(gotMembers)
		if diff := cmp.Diff(wantMembers, gotMembers); diff != "" {
			t.Errorf("role %q has unexpected members (-want +got):\n%s", wantRole, diff)
		}
	}
}
