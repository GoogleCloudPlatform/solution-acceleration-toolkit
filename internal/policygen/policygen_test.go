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
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

const fakeProjectNumber = "123"

type Fake struct{}

func (*Fake) CmdRun(*exec.Cmd) error { return nil }

func (*Fake) CmdOutput(cmd *exec.Cmd) ([]byte, error) {
	cmdStr := strings.Join(cmd.Args, " ")
	if contains(cmdStr, "gcloud projects describe", "--format json") {
		return []byte(fmt.Sprintf("{\"projectNumber\": \"%s\"}", fakeProjectNumber)), nil
	}

	return nil, nil
}

func (*Fake) CmdCombinedOutput(*exec.Cmd) ([]byte, error) { return nil, nil }

func contains(s string, subs ...string) bool {
	for _, sub := range subs {
		if !strings.Contains(s, sub) {
			return false
		}
	}
	return true
}

// TestExamples is a basic test for the policygen to ensure it runs without error on the examples.
func TestExamples(t *testing.T) {

	type wantDir struct {
		path           string
		wantFilesCount int
		wantFiles      []string // Check some files.
	}

	tests := []struct {
		configPath string
		statePaths []string
		wantDirs   []wantDir
	}{
		{
			"../../examples/policygen/config.hcl",
			// A single state file that does not have the .tfstate extension should still work.
			[]string{"testdata/state"},
			[]wantDir{
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "organization_12345678"),
					2,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudbuild_builds_editor.yaml",
					},
				},
			},
		},
		{
			"../../examples/policygen/config.hcl",
			[]string{"testdata/org.tfstate"},
			[]wantDir{
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "organization_12345678"),
					11,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudasset_viewer.yaml",
					},
				},
			},
		},
		{
			"../../examples/policygen/config.yaml",
			[]string{"testdata/subfolder/project.tfstate"},
			[]wantDir{
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "project_123"),
					9,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_editor.yaml",
						"iam_allow_bindings_owner.yaml",
						"iam_allow_bindings_cloudsql_client.yaml",
						"iam_allow_bindings_custom_osloginprojectget_6afd.yaml",
					},
				},
			},
		},
		{
			"../../examples/policygen/config.hcl",
			// Multiple state files.
			[]string{"testdata/state", "testdata/subfolder/project.tfstate"},
			[]wantDir{
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "organization_12345678"),
					2,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudbuild_builds_editor.yaml",
					},
				},
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "project_123"),
					9,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_editor.yaml",
						"iam_allow_bindings_owner.yaml",
						"iam_allow_bindings_cloudsql_client.yaml",
						"iam_allow_bindings_custom_osloginprojectget_6afd.yaml",
					},
				},
			},
		},
		{
			"../../examples/policygen/config.hcl",
			// One state file, one directory.
			[]string{"testdata/state", "testdata/subfolder"},
			[]wantDir{
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "organization_12345678"),
					2,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudbuild_builds_editor.yaml",
					},
				},
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "project_123"),
					9,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_editor.yaml",
						"iam_allow_bindings_owner.yaml",
						"iam_allow_bindings_cloudsql_client.yaml",
						"iam_allow_bindings_custom_osloginprojectget_6afd.yaml",
					},
				},
			},
		},
		{
			"../../examples/policygen/config.yaml",
			[]string{"testdata"},
			[]wantDir{
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "organization_12345678"),
					11,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_cloudasset_viewer.yaml",
					},
				},
				{
					filepath.Join(forsetiOutputRoot, "policies", "constraints", "project_123"),
					9,
					[]string{
						"iam_allow_roles.yaml",
						"iam_allow_bindings_editor.yaml",
						"iam_allow_bindings_owner.yaml",
						"iam_allow_bindings_cloudsql_client.yaml",
						"iam_allow_bindings_custom_osloginprojectget_6afd.yaml",
					},
				},
			},
		},
	}

	common := []wantDir{
		{
			filepath.Join(forsetiOutputRoot, "policies", "constraints", "overall"),
			12,
			[]string{
				"bigquery_allow_locations.yaml",
			},
		},
	}

	for _, tc := range tests {
		tmp, err := ioutil.TempDir("", "")
		if err != nil {
			t.Fatalf("ioutil.TempDir = %v", err)
		}
		defer os.RemoveAll(tmp)

		args := &RunArgs{
			ConfigPath: tc.configPath,
			StatePaths: tc.statePaths,
			OutputPath: tmp,
		}

		if err := Run(context.Background(), &Fake{}, args); err != nil {
			t.Fatalf("policygen.Run(%+v) = %v", args, err)
		}

		// Append common output dir and files.
		wantDirs := append(common, tc.wantDirs...)

		// Check for the existence of policy folders and files.
		for _, d := range wantDirs {
			dirPath := filepath.Join(tmp, d.path)
			if _, err := os.Stat(dirPath); err != nil {
				t.Errorf("os.Stat dir %q = %v", d, err)
			}

			fs, err := ioutil.ReadDir(dirPath)
			if err != nil {
				t.Fatalf("ioutil.ReadDir(%q) = %v", d, err)
			}

			if len(fs) != d.wantFilesCount {
				t.Errorf("retrieved number of files differ for dir %q from config %q and state %q: got %d, want %d", dirPath, tc.configPath, tc.statePaths, len(fs), d.wantFilesCount)
			}

			for _, f := range d.wantFiles {
				path := filepath.Join(dirPath, f)
				if _, err := os.Stat(path); err != nil {
					t.Errorf("os.Stat file %q = %v", path, err)
				}
			}
		}
	}
}
