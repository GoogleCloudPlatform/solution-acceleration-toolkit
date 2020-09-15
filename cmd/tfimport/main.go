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
// $ go run . [--input_dir=/path/to/config]
package main

import (
	"flag"
	"log"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport"
)

var (
	inputDir      = flag.String("input_dir", ".", "Path to the directory containing Terraform configs.")
	terraformPath = flag.String("terraform_path", "terraform", "Name or path to the terraform binary to use.")
	dryRun        = flag.Bool("dry_run", false, "Run in dry-run mode, which only prints the import commands without running them.")
	interactive   = flag.Bool("interactive", true, "Interactively ask for user input when import information cannot be\nautomatically determined.")
	showVersion   = flag.Bool("version", false, "show version and exit")
)

func main() {
	flag.Parse()

	if *showVersion {
		cmd.ShowVersion()
	}

	if *inputDir == "" {
		log.Fatalf("--input_dir must be set and not be empty")
	}
	// Determine the runners to use.
	rn := &runner.Default{}
	var importRn runner.Runner
	if *dryRun {
		importRn = &runner.Dry{}
		log.Printf("Dry run mode, logging commands but not executing any imports.")
	} else {
		importRn = &runner.Default{}
	}

	args := &tfimport.RunArgs{
		InputDir:      *inputDir,
		TerraformPath: *terraformPath,
		DryRun:        *dryRun,
		Interactive:   *interactive,
	}

	if err := tfimport.Run(rn, importRn, args); err != nil {
		log.Fatalf("Failed to import resources: %v", err)
	}
}
