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
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/fileutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/jsonschema"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/licenseutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/version"
	"github.com/otiai10/copy"
)

// Options is the options for tfengine execution.
type Options struct {
	Format      bool
	AddLicenses bool
	CacheDir    string

	// Leave empty to generate all templates.
	WantedTemplates map[string]bool
}

// Run executes the main tfengine logic.
func Run(confPath, outPath string, opts *Options) error {
	var err error
	confPath, err = fileutil.Expand(confPath)
	if err != nil {
		return err
	}
	outPath, err = fileutil.Expand(outPath)
	if err != nil {
		return err
	}

	c, err := loadConfig(confPath, nil)
	if err != nil {
		return err
	}

	compat, err := version.IsCompatible(c.Version)
	if err != nil {
		return err
	}
	if !compat {
		return fmt.Errorf("Binary version %v incompatible with template version constraint %v in %v", cmd.Version, c.Version, confPath)
	}

	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	if err := addGitIgnore(tmpDir); err != nil {
		return err
	}

	if err := dump(c, filepath.Dir(confPath), opts.CacheDir, tmpDir, opts.WantedTemplates); err != nil {
		return err
	}

	if err := os.MkdirAll(outPath, 0755); err != nil {
		return fmt.Errorf("mkdir %q: %v", outPath, err)
	}

	var errs []string

	if opts.AddLicenses {
		if err := licenseutil.AddLicense(tmpDir); err != nil {
			errs = append(errs, fmt.Sprintf("add license header: %v", err))
		}
	}

	if opts.Format {
		if err := hcl.FormatDir(&runner.Default{Quiet: true}, tmpDir); err != nil {
			errs = append(errs, fmt.Sprintf("format output dir: %v", err))
		}
	}

	if err := copy.Copy(tmpDir, outPath); err != nil {
		errs = append(errs, fmt.Sprintf("copy temp dir to output dir: %v", err))
	}

	if len(errs) > 0 {
		return errors.New(strings.Join(errs, "\n"))
	}
	return nil
}

func dump(conf *Config, pwd, cacheDir, outputPath string, wantedTemplates map[string]bool) error {
	for _, ti := range conf.Templates {
		// If a templates filter was provided, check against it.
		if len(wantedTemplates) > 0 {
			if _, ok := wantedTemplates[ti.Name]; !ok {
				continue
			}

			// Mark it so we can report on wrong template values at the end.
			// Don't delete, to avoid modifying the underlying data structure.
			wantedTemplates[ti.Name] = false
		}

		if err := dumpTemplate(conf, pwd, cacheDir, outputPath, ti); err != nil {
			return fmt.Errorf("template %q: %v", ti.Name, err)
		}
	}

	// Report on any templates that were supposed to be generated but weren't.
	// This most likely indicates a misspelling.
	var missingTemplates []string
	for t, missed := range wantedTemplates {
		if missed {
			missingTemplates = append(missingTemplates, t)
		}
		// Unmark.
		wantedTemplates[t] = true
	}
	if len(missingTemplates) > 0 {
		return fmt.Errorf("templates not found in engine config: %v", strings.Join(missingTemplates, ","))
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
		rp, err := fileutil.Fetch(ti.RecipePath, pwd, cacheDir)
		if err != nil {
			return err
		}
		rc, err := loadConfig(rp, data)
		if err != nil {
			return fmt.Errorf("load recipe %q: %v", rp, err)
		}

		compat, err := version.IsCompatible(rc.Version)
		if err != nil {
			return err
		}
		if !compat {
			return fmt.Errorf("binary version %v incompatible with template version constraint %v in %v", cmd.Version, rc.Version, rp)
		}

		// Validate the schema, if present.
		if len(rc.Schema) > 0 {
			// Only check against unmerged template data so we can disallow additional properties in the schema.
			if err := jsonschema.ValidateMap(rc.Schema, ti.Data); err != nil {
				return fmt.Errorf("recipe %q: %v", rp, err)
			}
		}

		// Each recipe could have a top-level data block. Keep it and merge, instead of overrwriting.
		if err := template.MergeData(rc.Data, data); err != nil {
			return err
		}

		if err := dump(rc, filepath.Dir(rp), cacheDir, outputPath, nil); err != nil {
			return fmt.Errorf("recipe %q: %v", rp, err)
		}

	case ti.ComponentPath != "":
		// Fetch the component, which could be remote.
		cp, err := fileutil.Fetch(ti.ComponentPath, pwd, cacheDir)
		if err != nil {
			return err
		}

		write := template.WriteDir

		// If the component path is a single file,
		// treat the output_path as a file name and only write that out.
		// Otherwise, treat as directory path
		info, err := os.Stat(cp)
		if err != nil {
			return fmt.Errorf("stat %q: %v", cp, err)
		}
		if info.Mode().IsRegular() {
			write = template.WriteFile
		}

		if err := write(cp, outputPath, data); err != nil {
			return fmt.Errorf("component %q: %v", cp, err)
		}
	}
	return nil
}

func addGitIgnore(path string) error {
	data := []byte(`# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*
`)
	if err := ioutil.WriteFile(filepath.Join(path, ".gitignore"), data, 0644); err != nil {
		return err
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
