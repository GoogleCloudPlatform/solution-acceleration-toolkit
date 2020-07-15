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

			// Run plan on live dir to verify configs.
			path := filepath.Join(tmp, "live")

			// Convert the configs not reference a GCS backend as the state bucket does not exist.
			if err := ConvertToLocalBackend(path); err != nil {
				t.Fatalf("ConvertToLocalBackend(%v): %v", path, err)
			}

			plan := exec.Command("terragrunt", "plan-all")
			plan.Dir = path
			if b, err := plan.CombinedOutput(); err != nil {
				t.Errorf("command %v in %q: %v\n%v", plan.Args, path, err, string(b))
			}
		})
	}
}
