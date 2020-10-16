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
	"testing"
)

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
		// https://github.com/golang/go/wiki/CommonMistakes#using-goroutines-on-loop-iterator-variables
		ex := ex
		t.Run(filepath.Base(ex), func(t *testing.T) {
			t.Parallel()
			tmp, err := ioutil.TempDir("", "")
			if err != nil {
				t.Fatalf("ioutil.TempDir = %v", err)
			}
			defer os.RemoveAll(tmp)

			if err := Run(ex, tmp, &Options{Format: true, CacheDir: tmp}); err != nil {
				t.Fatalf("tfengine.Run(%q, %q) = %v", ex, tmp, err)
			}

			// Run plan to verify configs.
			fs, err := ioutil.ReadDir(tmp)
			if err != nil {
				t.Fatalf("ioutil.ReadDir = %v", err)
			}

			// Skip these dirs as they use data sources that are not available until dependencies have been deployed.
			skipDirs := map[string]bool{
				"cicd":       true,
				"kubernetes": true,
			}
			for _, f := range fs {
				if !f.IsDir() || skipDirs[f.Name()] {
					continue
				}
				dir := filepath.Join(tmp, f.Name())

				// Convert the configs not reference a GCS backend as the state bucket does not exist.
				if err := ConvertToLocalBackend(dir); err != nil {
					t.Fatalf("ConvertToLocalBackend(%v): %v", dir, err)
				}
				init := exec.Command("terraform", "init")
				init.Dir = dir
				if b, err := init.CombinedOutput(); err != nil {
					t.Errorf("command %v in %q: %v\n%v", init.Args, dir, err, string(b))
				}

				plan := exec.Command("terraform", "plan")
				plan.Dir = dir
				if b, err := plan.CombinedOutput(); err != nil {
					t.Errorf("command %v in %q: %v\n%v", plan.Args, dir, err, string(b))
				}
			}
		})
	}
}

func TestRunRemotePath(t *testing.T) {
	conf := `
data = {
  parent_type = "folder"
  parent_id   = "123"
}

template "recipe" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/org_policies.hcl?ref=templates-v0.1.0"
  data = {
    allowed_policy_member_customer_ids = [
      "example_customer_id",
    ]
  }
}

template "component" {
  component_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/policygen/org_policies?ref=templates-v0.1.0"
  data = {
    allowed_policy_member_customer_ids = [
      "example_customer_id",
    ]
  }
}

template "component" {
	component_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/policygen/org_policies/main.tf?ref=templates-v0.1.0"
	output_path = "policies.tf"
  data = {
    allowed_policy_member_customer_ids = [
      "example_customer_id",
    ]
  }
}`
	confFile, err := ioutil.TempFile("", "*.hcl")
	if err != nil {
		t.Fatalf("ioutil.TempFile = %v", err)
	}
	defer os.Remove(confFile.Name())

	if _, err := confFile.Write([]byte(conf)); err != nil {
		t.Fatalf("confFile.Write = %v", err)
	}

	outputDir, err := ioutil.TempDir("", "")
	if err != nil {
		t.Fatalf("ioutil.TempDir = %v", err)
	}
	defer os.RemoveAll(outputDir)

	if err := Run(confFile.Name(), outputDir, &Options{Format: true, CacheDir: outputDir}); err != nil {
		t.Fatalf("tfengine.Run(%q, %q) = %v", confFile.Name(), outputDir, err)
	}
}
