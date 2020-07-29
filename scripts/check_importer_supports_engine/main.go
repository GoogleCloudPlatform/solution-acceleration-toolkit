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

// Generates configs from the full example, inits all modules, and checks if any resources are not supported by the importer.
// Meant to be run from the repo root like so:
// go run ./scripts/check_importer_supports_engine

package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport"
)

const examplesDir = "examples/tfengine"

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	examples, err := filepath.Glob(filepath.Join(examplesDir, "*.hcl"))
	if err != nil {
		return fmt.Errorf("glob .hcl files under %v: %v", examplesDir, err)
	}

	if len(examples) == 0 {
		return fmt.Errorf("found no examples")
	}

	unsupported := make(map[string]bool)
	for _, ex := range examples {
		if err := resourcesFromConfig(ex, unsupported); err != nil {
			return fmt.Errorf("finding resources from %v: %v", ex, err)
		}
	}

	resources := make([]string, 0, len(unsupported))
	for r := range unsupported {
		resources = append(resources, r)
	}

	sort.Strings(resources)
	fmt.Println(strings.Join(resources, "\n"))

	return nil
}

// resourcesFromConfig generates configs from an engine config, and populates the map unsupported with unsupported resources
func resourcesFromConfig(configPath string, unsupported map[string]bool) error {
	// Create tmpdir for outputting the configs
	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		return fmt.Errorf("ioutil.TempDir = %v", err)
	}
	defer os.RemoveAll(tmp)

	// Generate configs from the top-level config
	if err := tfengine.Run(configPath, tmp, &tfengine.Options{Format: false, CacheDir: tmp}); err != nil {
		return fmt.Errorf("tfengine.Run(%q, %q) = %v", configPath, tmp, err)
	}

	// Run plan to verify configs.
	fs, err := ioutil.ReadDir(tmp)
	if err != nil {
		return fmt.Errorf("ioutil.ReadDir = %v", err)
	}

	for _, f := range fs {
		if !f.IsDir() {
			continue
		}
		dir := filepath.Join(tmp, f.Name())

		// Convert the configs not reference a GCS backend as the state bucket does not exist.
		if err := tfengine.ConvertToLocalBackend(dir); err != nil {
			return fmt.Errorf("ConvertToLocalBackend(%v): %v", dir, err)
		}
		init := exec.Command("terraform", "init")
		init.Dir = dir
		if b, err := init.CombinedOutput(); err != nil {
			return fmt.Errorf("command %v in %q: %v\n%v", init.Args, fn, err, string(b))
		}
		if err := addResources(dir, unsupported); err != nil {
			return fmt.Errorf("add resources from %q: %v", fn, err)
		}
	}
	return nil
}

var resourceRE = regexp.MustCompile(`(?s)resource "(.*?)"`)

// addResources search for resource declarations in .tf files and adds them to the map unsupported if they're importable and not supported.
func addResources(path string, unsupported map[string]bool) error {
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
		match := resourceRE.FindAllStringSubmatch(string(b), -1)
		for _, m := range match {
			resource := m[len(m)-1]
			if _, ok := unsupported[resource]; ok {
				continue
			}

			// Skip if it's supported or not importable.
			_, supported := tfimport.Importers[resource]
			_, unimportable := tfimport.Unimportable[resource]
			if supported || unimportable {
				continue
			}

			unsupported[resource] = true
		}

		return nil
	}

	if err := filepath.Walk(path, fn); err != nil {
		return fmt.Errorf("filepath.Walk = %v", err)
	}

	return nil
}
