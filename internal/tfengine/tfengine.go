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

// Package tfengine implements the Terraform Engine.
package tfengine

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/otiai10/copy"
)

func Run(confPath, outPath string) error {
	var err error
	confPath, err = pathutil.Expand(confPath)
	if err != nil {
		return err
	}
	outPath, err = pathutil.Expand(outPath)
	if err != nil {
		return err
	}

	c, err := loadConfig(confPath, nil)
	if err != nil {
		return err
	}
	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	if err := dump(c, filepath.Dir(confPath), tmpDir); err != nil {
		return err
	}

	if err := os.MkdirAll(outPath, 0755); err != nil {
		return fmt.Errorf("failed to mkdir %q: %v", outPath, err)
	}

	return copy.Copy(tmpDir, outPath)
}

func dump(conf *Config, root, outputPath string) error {
	for _, ti := range conf.Templates {
		outputPath := filepath.Join(outputPath, ti.OutputPath)

		if ti.Data == nil {
			ti.Data = make(map[string]interface{})
		}
		if err := template.MergeData(ti.Data, conf.Data, ti.Flatten); err != nil {
			return err
		}

		switch {
		case ti.RecipePath != "":
			rp, err := pathutil.Expand(ti.RecipePath)
			if err != nil {
				return err
			}
			if !filepath.IsAbs(rp) {
				rp = filepath.Join(root, rp)
			}
			rc, err := loadConfig(rp, ti.Data)
			if err != nil {
				return fmt.Errorf("load recipe %q: %v", rp, err)
			}
			rc.Data = ti.Data
			if err := dump(rc, filepath.Dir(rp), outputPath); err != nil {
				return fmt.Errorf("recipe %q: %v", rp, err)
			}
		case ti.ComponentPath != "":
			cp, err := pathutil.Expand(ti.ComponentPath)
			if err != nil {
				return err
			}
			if !filepath.IsAbs(cp) {
				cp = filepath.Join(root, cp)
			}
			if err := template.WriteDir(cp, outputPath, ti.Data); err != nil {
				return fmt.Errorf("component %q: %v", cp, err)
			}
		}
	}
	return nil
}

// backendRE is a regex to capture GCS backend blocks in configs.
// The 's' and 'U' flags allow capturing multi line backend blocks in a lazy manner.
var backendRE = regexp.MustCompile(`(?sU)backend "gcs" {.*}`)

// ConvertToLocalBackend converts all the Terraform backend blocks to "local".
// path should be a path to the root of the configs generated by the Engine.
func ConvertToLocalBackend(path string) error {
	// Overwrite root terragrunt file with empty file so it doesn't try to setup remote backend.
	tpath := filepath.Join(path, "terragrunt.hcl")
	if err := ioutil.WriteFile(tpath, nil, 0664); err != nil {
		return fmt.Errorf("write terragrunt root at %q: %v", tpath, err)
	}

	// Replace all GCS backend blocks with local.
	fn := func(path string, info os.FileInfo, err error) error {
		if filepath.Ext(path) != ".tf" {
			return nil
		}

		b, err := ioutil.ReadFile(path)
		if err != nil {
			return fmt.Errorf("read file %q: %v", path, err)
		}

		b = backendRE.ReplaceAll(b, nil)
		if err := ioutil.WriteFile(path, b, 0644); err != nil {
			return fmt.Errorf("write file %q: %v", path, err)
		}

		return nil
	}

	if err := filepath.Walk(path, fn); err != nil {
		return fmt.Errorf("walk %qs: %v", path, err)
	}

	return nil
}
