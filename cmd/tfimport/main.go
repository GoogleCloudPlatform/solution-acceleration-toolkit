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

// The Terraform Importer imports resources from existing infrastructure into Terraform configs.
// Requires Terraform to be installed and for authentication to be configured for each provider in the Terraform configs provider blocks.
//
// Usage:
// $ go run . [--input_dir=/path/to/config] [--resource_types 'google_storage_bucket.bucket' --resources 'google_resource_manager_lien.lien']
package main

import (
	"flag"
	"fmt"
	"log"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport"
)

// From https://stackoverflow.com/a/28323276
type mapFlag map[string]bool

func (i *mapFlag) String() string {
	return "my string representation"
}

func (i *mapFlag) Set(value string) error {
	(*i)[value] = true
	return nil
}

var resourcesFlag = make(mapFlag)

var (
	inputDir      = flag.String("input_dir", ".", "Path to the directory containing Terraform configs.")
	terraformPath = flag.String("terraform_path", "terraform", "Name or path to the terraform binary to use.")
	dryRun        = flag.Bool("dry_run", false, "Run in dry-run mode, which only prints the import commands without running them.")
	interactive   = flag.Bool("interactive", true, "Interactively ask for user input when import information cannot be\nautomatically determined.")
	showVersion   = flag.Bool("version", false, "show version and exit")
)

func main() {
	flag.Var(&resourcesFlag, "resource_types", "Specific resource types to import, specified as terraform resource names (e.g. 'google_storage_bucket', 'google_resource_manager_lien'). Leave empty to import all.")

	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	flag.Parse()

	if *showVersion {
		cmd.ShowVersion()
		return nil
	}

	if *inputDir == "" {
		return fmt.Errorf("--input_dir must be set and not be empty")
	}
	// Determine the runners to use.
	rn := &runner.Default{}
	var importRn runner.Runner
	if *dryRun {
		importRn = &runner.Dry{}
		log.Printf("Dry run mode, logging commands but not executing any imports.")
	} else {
		// Use the Multi runner to print temporary output in case the terraform import command freezes.
		importRn = &runner.Multi{}
	}

	args := &tfimport.RunArgs{
		InputDir:              *inputDir,
		TerraformPath:         *terraformPath,
		DryRun:                *dryRun,
		Interactive:           *interactive,
		SpecificResourceTypes: resourcesFlag,
	}

	if err := tfimport.Run(rn, importRn, args); err != nil {
		return fmt.Errorf("failed to import resources: %v", err)
	}

	return nil
}
