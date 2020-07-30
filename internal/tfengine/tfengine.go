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

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/jsonschema"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/licenseutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/policygen"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/otiai10/copy"
)

// Options is the options for tfengine execution.
type Options struct {
	Format   bool
	CacheDir string
}

// Run executes the main tfengine logic.
func Run(confPath, outPath string, opts *Options) error {
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

	if err := dump(c, filepath.Dir(confPath), opts.CacheDir, tmpDir); err != nil {
		return err
	}

	if opts.Format {
		if err := hcl.FormatDir(&runner.Default{Quiet: true}, tmpDir); err != nil {
			return err
		}
	}

	if err := licenseutil.AddLicense(tmpDir); err != nil {
		return fmt.Errorf("add license header: %v", err)
	}

	if err := os.MkdirAll(outPath, 0755); err != nil {
		return fmt.Errorf("failed to mkdir %q: %v", outPath, err)
	}

	return copy.Copy(tmpDir, outPath)
}

func dump(conf *Config, pwd, cacheDir, outputPath string) error {
	for _, ti := range conf.Templates {
		if ti.Data == nil {
			ti.Data = make(map[string]interface{})
		}
		if err := dumpTemplate(conf, pwd, cacheDir, outputPath, ti); err != nil {
			return fmt.Errorf("template %q: %v", ti.Name, err)
		}
	}
	return nil
}

func dumpTemplate(conf *Config, pwd, cacheDir, outputPath string, ti *templateInfo) error {
	outputPath = filepath.Join(outputPath, ti.OutputPath)

	data := make(map[string]interface{})
	if err := template.MergeData(data, conf.Data); err != nil {
		return err
	}
	flattenedData, err := template.FlattenData(data, ti.Flatten)
	if err != nil {
		return err
	}
	// Merge flattened data into template data so that it gets checked by the schema check later.
	if err := template.MergeData(ti.Data, flattenedData); err != nil {
		return err
	}
	if err := template.MergeData(data, ti.Data); err != nil {
		return err
	}

	switch {
	case ti.RecipePath != "":
		rp, err := pathutil.Fetch(ti.RecipePath, pwd, cacheDir)
		if err != nil {
			return err
		}
		rc, err := loadConfig(rp, data)
		if err != nil {
			return fmt.Errorf("load recipe %q: %v", rp, err)
		}

		// Validate the schema, if present.
		if len(rc.Schema) > 0 {
			// Only check against unmerged template data so we can disallow additional properties in the schema.
			if err := jsonschema.ValidateMap(rc.Schema, ti.Data); err != nil {
				return fmt.Errorf("recipe %q: %v", rp, err)
			}
		} else if ti.Name == "org_policies" {
			// Only check against unmerged template data so we can disallow additional properties in the schema.
			if err := policygen.ValidateOrgPoliciesConfig(ti.Data); err != nil {
				return err
			}
		}

		// Each recipe could have a top-level data block. Keep it and merge, instead of overrwriting.
		if rc.Data == nil {
			rc.Data = make(map[string]interface{})
		}

		if err := template.MergeData(rc.Data, data); err != nil {
			return err
		}

		if err := dump(rc, filepath.Dir(rp), cacheDir, outputPath); err != nil {
			return fmt.Errorf("recipe %q: %v", rp, err)
		}

	case ti.ComponentPath != "":
		// Fetch the component, which could be remote.
		cp, err := pathutil.Fetch(ti.ComponentPath, pwd, cacheDir)
		if err != nil {
			return err
		}

		// If the component path is a single file,
		// treat the output_path as a file name and only write that out.
		// Otherwise, treat as directory path
		write := template.WriteDir
		if pathutil.IsFile(cp) {
			write = template.WriteFile
		}

		if err := write(cp, outputPath, data); err != nil {
			return fmt.Errorf("component %q: %v", cp, err)
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
	// Replace all GCS backend blocks with local.
	fn := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("walk path %q: %v", path, err)
		}

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
