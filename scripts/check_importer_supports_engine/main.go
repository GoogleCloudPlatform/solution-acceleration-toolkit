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

const full = "examples/tfengine/full.hcl"

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	if _, err := os.Stat(full); os.IsNotExist(err) {
		return fmt.Errorf("example file %v does not exist: %v", full, err)
	}

	// Create tmpdir for outputting the configs
	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		return fmt.Errorf("ioutil.TempDir = %v", err)
	}
	defer os.RemoveAll(tmp)

	// Generate configs from full example
	if err := tfengine.Run(full, tmp); err != nil {
		return fmt.Errorf("tfengine.Run(%q, %q) = %v", full, tmp, err)
	}

	// Convert all Terraform backend blocks to local
	path := filepath.Join(tmp, "live")
	if err := tfengine.ConvertToLocalBackend(path); err != nil {
		return fmt.Errorf("ConvertToLocalBackend(%v): %v", path, err)
	}

	// Initialize all modules in order to create and fill the .terraform/ dirs
	// Use plan-all because init-all tries to init an empty directory and fails
	// plan-all still ends up calling init recursively, but doesn't fail
	plan := exec.Command("terragrunt", "plan-all")
	plan.Dir = path

	// Use CombinedOutput because err is just "exit status 1" without details
	if out, err := plan.CombinedOutput(); err != nil {
		return fmt.Errorf("command %v in %q: %v\n%v", plan.Args, plan.Dir, err, string(out))
	}

	// Find all resources
	resources, err := findAllResources(path)
	if err != nil {
		return fmt.Errorf("finding resources: %v", err)
	}

	// Filter supported and unimportable resources
	unsupported := []string{}
	for _, r := range resources {
		_, unimportable := tfimport.Unimportable[r]
		_, supported := tfimport.Importers[r]
		if unimportable || supported {
			continue
		}
		unsupported = append(unsupported, r)
	}

	if len(unsupported) > 0 {
		sort.Strings(unsupported)
		fmt.Println(strings.Join(unsupported, "\n"))
	}

	return nil
}

var resourceRE = regexp.MustCompile(`(?s)resource "(.*?)"`)

func findAllResources(path string) (resources []string, err error) {
	set := make(map[string]bool)

	// Find all resource delcarations.
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
			if _, ok := set[resource]; !ok {
				set[resource] = true
			}
		}

		return nil
	}

	if err := filepath.Walk(path, fn); err != nil {
		return []string{}, fmt.Errorf("filepath.Walk = %v", err)
	}

	for resource := range set {
		resources = append(resources, resource)
	}
	return resources, nil
}
