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
// Meant to be run from the scripts/ folder like so:
// go run importer_engine_support_check.go

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

func main() {
	full := "../examples/tfengine/full.hcl"
	if _, err := os.Stat(full); os.IsNotExist(err) {
		log.Fatalf("example file %v does not exist: %v", full, err)
	}

	log.Printf("Creating tmpdir for outputting the configs")
	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		log.Fatalf("ioutil.TempDir = %v", err)
	}
	defer os.RemoveAll(tmp)

	log.Printf("Generating configs from %v to %v", full, tmp)
	if err := tfengine.Run(full, tmp); err != nil {
		log.Fatalf("tfengine.Run(%q, %q) = %v", full, tmp, err)
	}

	log.Printf("Converting all Terraform backend blocks to local")
	path := filepath.Join(tmp, "live")
	tfengine.ConvertToLocalBackend(path)

	log.Printf("Initializing all modules in order to create and fill the .terraform/ dirs.")
	plan := exec.Command("terragrunt", "plan-all")
	plan.Dir = path
	if b, err := plan.CombinedOutput(); err != nil {
		log.Printf("command %v in %q: %v\n%v", plan.Args, plan.Dir, err, string(b))
	}

	log.Printf("Finding all resources")
	resources, err := findAllResources(path)
	if err != nil {
		log.Fatalf("finding resources: %v", err)
	}

	log.Printf("Filtering supported and unimportable resources")
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
		log.Printf("Found unsupported resources:\n%v", strings.Join(unsupported, "\n"))
	} else {
		log.Println("All importable resources supported by importer!")
	}
}

var resourceRE = regexp.MustCompile(`(?s)resource "(.*?)"`)

func findAllResources(path string) (resources []string, err error) {
	set := make(map[string]bool)

	// Find all resource delcarations.
	fn := func(path string, info os.FileInfo, err error) error {
		if filepath.Ext(path) != ".tf" {
			return nil
		}

		b, err := ioutil.ReadFile(path)
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
