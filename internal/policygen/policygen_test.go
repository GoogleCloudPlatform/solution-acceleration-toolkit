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

package policygen

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

// TestExamples is a basic test for the policygen to ensure it runs without error on the examples.
func TestExamples(t *testing.T) {
	exs, err := filepath.Glob("../../examples/policygen/*.yaml")
	if err != nil {
		t.Fatalf("filepath.Glob = %v", err)
	}

	if len(exs) == 0 {
		t.Error("found no examples")
	}

	for _, ex := range exs {
		t.Run(filepath.Base(ex), func(t *testing.T) {
			tmp, err := ioutil.TempDir("", "")
			if err != nil {
				t.Fatalf("ioutil.TempDir = %v", err)
			}
			defer os.RemoveAll(tmp)

			args := &RunArgs{
				InputConfig: ex,
				OutputDir:   tmp,
			}

			if err := Run(args); err != nil {
				t.Fatalf("policygen.Run(%+v) = %v", args, err)
			}

			// Check for the existence of policy folders.
			if _, err := os.Stat(filepath.Join(tmp, "forseti_policies")); err != nil {
				t.Errorf("os.Stat forseti_policies dir = %v", err)
			}
			if _, err := os.Stat(filepath.Join(tmp, "gcp_org_policies")); err != nil {
				t.Fatalf("os.Stat gcp_organization_policies dir = %v", err)
			}
		})
	}
}
