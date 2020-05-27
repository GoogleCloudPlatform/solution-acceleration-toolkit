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
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

type Fake struct{}

func (*Fake) CmdRun(*exec.Cmd) error {
	return nil
}

func (*Fake) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	contains := func(s string, subs ...string) bool {
		for _, sub := range subs {
			if !strings.Contains(s, sub) {
				return false
			}
		}
		return true
	}

	cmdStr := strings.Join(cmd.Args, " ")
	if contains(cmdStr, "gcloud projects describe", "--format json") {
		return []byte("{\"projectNumber\": \"123\"}"), nil
	}

	return nil, nil
}

func (*Fake) CmdCombinedOutput(*exec.Cmd) ([]byte, error) {
	return nil, nil
}

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
				ConfigPath: ex,
				StatePath:  "../terraform/testdata/test.tfstate",
				OutputPath: tmp,
			}

			if err := Run(&Fake{}, args); err != nil {
				t.Fatalf("policygen.Run(%+v) = %v", args, err)
			}

			// Check for the existence of policy folders and files.
			dirs := []struct {
				path           string
				wantFilesCount int
				wantFiles      []string // Check some files.
			}{
				{
					filepath.Join(tmp, "forseti_policies", "overall"),
					11,
					[]string{
						"bigquery_allow_locations.yaml",
					}},
				{
					filepath.Join(tmp, "forseti_policies", "organization_12345678"),
					11,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudasset.viewer.yaml",
					}},
				{
					filepath.Join(tmp, "forseti_policies", "project_123"),
					6,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudsql.client.yaml",
					}},
				{
					filepath.Join(tmp, "gcp_org_policies"),
					3,
					[]string{
						"main.tf",
						"variables.tf",
						"terraform.tfvars",
					}},
			}

			for _, d := range dirs {
				if _, err := os.Stat(d.path); err != nil {
					t.Errorf("os.Stat dir %q = %v", d, err)
				}

				fs, err := ioutil.ReadDir(d.path)
				if err != nil {
					t.Fatalf("ioutil.ReadDir(%q) = %v", d, err)
				}

				if len(fs) != d.wantFilesCount {
					t.Errorf("retrieved number of files differ for dir %q: got %d, want %d", d.path, len(fs), d.wantFilesCount)
				}

				for _, f := range d.wantFiles {
					path := filepath.Join(d.path, f)
					if _, err := os.Stat(path); err != nil {
						t.Errorf("os.Stat file %q = %v", path, err)
					}
				}
			}
		})
	}
}
