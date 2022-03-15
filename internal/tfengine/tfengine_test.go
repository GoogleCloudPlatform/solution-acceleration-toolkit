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

// Prerequisites: the terraform binary must be available in $PATH.

package tfengine

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
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
			runPlanOnDeployments(t, tmp)
		})
	}
}

func runPlanOnDeployments(t *testing.T, dir string) {
	fn := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("walk path %q: %v", path, err)
		}

		// Skip these dirs as they use data sources that are not available until dependencies have been deployed.
		skipDirs := map[string]bool{
			"cicd":         true,
			"kubernetes":   true,
			"monitor":      true,
			"project_data": true,
		}

		if !info.IsDir() {
			return nil
		}

		if skipDirs[info.Name()] {
			return filepath.SkipDir
		}

		// Skip if there are no .tf files directly under the dir (without considering subdirs).
		fs, err := ioutil.ReadDir(path)
		if err != nil {
			return fmt.Errorf("ioutil.ReadDir = %v", err)
		}
		hasTerraformFiles := false
		for _, f := range fs {
			if strings.HasSuffix(f.Name(), ".tf") {
				hasTerraformFiles = true
				break
			}
		}

		if !hasTerraformFiles {
			return nil
		}

		// Convert the configs not reference a GCS backend as the state bucket does not exist.
		if err := ConvertToLocalBackend(path); err != nil {
			return fmt.Errorf("ConvertToLocalBackend(%v): %v", path, err)
		}
		init := exec.Command("terraform", "init")
		init.Dir = path
		if b, err := init.CombinedOutput(); err != nil {
			return fmt.Errorf("command %v in %q: %v\n%v", init.Args, path, err, string(b))
		}

		plan := exec.Command("terraform", "plan")
		plan.Dir = path
		if b, err := plan.CombinedOutput(); err != nil {
			return fmt.Errorf("command %v in %q: %v\n%v", plan.Args, path, err, string(b))
		}
		return nil
	}

	if err := filepath.Walk(dir, fn); err != nil {
		t.Fatal(err)
	}
}

func TestRunRemotePath(t *testing.T) {
	conf := `
data = {
  parent_type = "folder"
  parent_id   = "123"
}

template "recipe" {
  recipe_path = "github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/org_policies.hcl?ref=templates-v0.1.0"
  data = {
    allowed_policy_member_customer_ids = [
      "example_customer_id",
    ]
  }
}

template "component" {
  component_path = "github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/policygen/org_policies?ref=templates-v0.1.0"
  data = {
    allowed_policy_member_customer_ids = [
      "example_customer_id",
    ]
  }
}

template "component" {
  component_path = "github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/policygen/org_policies/main.tf?ref=templates-v0.1.0"
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
