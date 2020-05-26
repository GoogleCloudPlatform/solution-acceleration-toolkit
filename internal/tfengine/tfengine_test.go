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

package tfengine

import (
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"testing"
)

var backendRE = regexp.MustCompile(`(?s)backend "gcs" {.*?}`)

// TestExamples is a basic test for the engine to ensure it runs without error on the examples.
func TestExamples(t *testing.T) {
	exs, err := filepath.Glob("../../examples/tfengine/*.hcl")
	if err != nil {
		t.Fatalf("filepath.Glob = %v", err)
	}

	if len(exs) == 0 {
		t.Error("found no examples")
	}

	for _, ex := range exs {
		ex := ex // capture range variable
		t.Run(filepath.Base(ex), func(t *testing.T) {
			t.Parallel()
			tmp, err := ioutil.TempDir("", "")
			if err != nil {
				t.Fatalf("ioutil.TempDir = %v", err)
			}
			defer os.RemoveAll(tmp)

			if err := Run(ex, tmp); err != nil {
				t.Fatalf("tfengine.Run(%q, %q) = %v", ex, tmp, err)
			}

			// Run plan on live dir to verify configs.
			path := filepath.Join(tmp, "live")

			convertToLocalBackend(t, path)

			plan := exec.Command("terragrunt", "plan-all")
			plan.Dir = path
			if b, err := plan.CombinedOutput(); err != nil {
				t.Fatalf("command %v in %q: %v\n%v", plan.Args, path, err, string(b))
			}
		})
	}
}

// convertToLocalBackend converts the Terraform and Terragrunt configs at path to not reference a GCS backend.
// This allows the test to run plan-all without causing Terraform to lookup the GCS state bucket.
func convertToLocalBackend(t *testing.T, path string) {
	// Overwrite root terragrunt file with empty file so it doesn't try to setup remote backend.
	if err := ioutil.WriteFile(filepath.Join(path, "terragrunt.hcl"), nil, 0664); err != nil {
		t.Fatalf("ioutil.Write terragrunt root file: %v", err)
	}

	// Replace all GCS backend blocks with local.
	fn := func(path string, info os.FileInfo, err error) error {
		if filepath.Ext(path) != ".tf" {
			return nil
		}

		b, err := ioutil.ReadFile(path)
		if err != nil {
			t.Fatalf("ioutil.ReadFile(%q) = %v", path, err)
		}

		b = backendRE.ReplaceAll(b, nil)
		if err := ioutil.WriteFile(path, b, 0644); err != nil {
			t.Fatalf("ioutil.WriteFile %q: %v", path, err)
		}

		return nil
	}

	if err := filepath.Walk(path, fn); err != nil {
		t.Fatalf("filepath.Walk = %v", err)
	}
}
