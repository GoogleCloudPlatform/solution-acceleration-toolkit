/*
 * Copyright 2020 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// The Terraform Importer imports resources from existing infrastructure into Terraform configs.
// Requires Terraform to be installed and for authentication to be configured for each provider in the Terraform configs provider blocks.
//
// Usage:
// $ go run . [--input_dir=/path/to/config] [--terraform_path=terragrunt]
package main

import (
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport/importer"
)

var (
	inputDir      = flag.String("input_dir", ".", "Path to the directory containing Terraform configs.")
	terraformPath = flag.String("terraform_path", "terraform", "Name or path to the terraform binary to use.\nThis could be i.e. 'terragrunt' or a path to\na different version of terraform.")
	dryRun        = flag.Bool("dry_run", false, "Run in dry-run mode, which only prints the import commands without running them.")
	interactive   = flag.Bool("interactive", true, "Interactively ask for user input when import information cannot be automatically determined.")
)

func main() {
	flag.Parse()

	if *inputDir == "" {
		log.Fatalf("--input_dir must be set and not be empty")
	}

	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	// Expand the config path (ex. expand ~).
	var err error
	*inputDir, err = pathutil.Expand(*inputDir)
	if err != nil {
		return fmt.Errorf("expand path %q: %v", *inputDir, err)
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

	// Create Terraform command runners.
	tfCmdOutput := func(args ...string) ([]byte, error) {
		cmd := exec.Command(*terraformPath, args...)
		cmd.Dir = *inputDir
		return rn.CmdOutput(cmd)
	}

	// Init is safe to run on an already-initialized config dir.
	if out, err := tfCmdOutput("init"); err != nil {
		return fmt.Errorf("init: %v\v%v", err, string(out))
	}

	// Generate and load the plan using a temp var.
	tmpfile, err := ioutil.TempFile("", "")
	if err != nil {
		return fmt.Errorf("create temp file: %v", err)
	}
	defer os.Remove(tmpfile.Name())
	planPath := tmpfile.Name()
	if out, err := tfCmdOutput("plan", "-out", planPath); err != nil {
		return fmt.Errorf("plan: %v\n%v", err, string(out))
	}
	b, err := tfCmdOutput("show", "-json", planPath)
	if err != nil {
		return fmt.Errorf("show: %v\n%v", err, string(b))
	}

	// Load only "create" changes.
	createChanges, err := terraform.ReadPlanChanges(b, []string{"create"})
	if err != nil {
		return fmt.Errorf("read Terraform plan changes: %q", err)
	}

	// Import all importable create changes.
	importedSomething := false
	var ie *importer.InsufficientInfoErr
	var errs []string
	var importCmds []string
	for _, cc := range createChanges {
		// Get the provider config values (pcv) for this particular resource.
		// This is needed to determine if it's possible to import the resource.
		pcv, err := terraform.ReadProviderConfigValues(b, cc.Kind, cc.Name)
		if err != nil {
			return fmt.Errorf("read provider config values from the Terraform plan: %q", err)
		}

		// Try to convert to an importable resource.
		ir, ok := tfimport.Importable(cc, pcv)
		if !ok {
			log.Printf("Resource %q of type %q not importable\n", cc.Address, cc.Kind)
			continue
		}

		log.Printf("Found importable resource: %q\n", ir.Change.Address)

		// Attempt the import.
		output, err := tfimport.Import(importRn, ir, *inputDir, *terraformPath, *interactive)

		// In dry-run mode, the output is the command to run.
		if *dryRun {
			importCmds = append(importCmds, output)
			continue
		}

		// Handle the different outcomes of the import attempt.
		switch {
		// err will only be nil when the import succeed.
		// Import succeeded, print the success output.
		case err == nil:
			// Import succeeded.
			fmt.Println(output)
			importedSomething = true

		// Check if the error indicates insufficient information.
		case errors.As(err, &ie):
			log.Println(err)
			log.Println("Skipping")

		// Check if error indicates resource is not importable or does not exist.
		// err will be `exit code 1` even when it failed because the resource is not importable or already exists.
		case tfimport.NotImportable(output):
			log.Printf("Import not supported by provider for resource %q\n", ir.Change.Address)
		case tfimport.DoesNotExist(output):
			log.Printf("Resource %q does not exist, not importing\n", ir.Change.Address)

		// Important to handle this last.
		default:
			log.Println(err)
			errs = append(errs, fmt.Sprintf("failed to import %q: %v\n%v", ir.Change.Address, err, output))
		}
	}

	if !importedSomething {
		log.Printf("No resources imported.")
	}

	if len(errs) > 0 {
		return fmt.Errorf("failed to import %v resources:\n%v", len(errs), strings.Join(errs, "\n"))
	}

	if *dryRun && len(importCmds) > 0 {
		log.Printf("Import commands:")
		fmt.Printf("cd %v\n", *inputDir)
		// The last arg in import could be several space-separated strings. These need to be quoted together.
		for _, c := range importCmds {
			args := strings.Split(c, " ")
			fmt.Printf("%v %v %v %q\n", args[0], args[1], args[2], strings.Join(args[3:], " "))
		}
	}

	return nil
}
