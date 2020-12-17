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

// policygen automates generation of Google-recommended Policy Library constraints based on your Terraform configs.
//
// Usage:
// $ policygen --config_path=examples/policygen/config.hcl --state_paths=/path/to/default.tfstate --output_path=/tmp/policies
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/policygen"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
)

var (
	configPath  = flag.String("config_path", "", "Path to the Policy Generator config.")
	statePaths  = flag.String("state_paths", "", "A comma-separated list of paths to Terraform states. Each entry can be a single local file, a local directory or a Google Cloud Storage bucket (gs://my-state-bucket). If a local directory or a bucket is given, then all .tfstate files will be read recursively.")
	outputPath  = flag.String("output_path", "", "Path to output directory to write generated policies")
	showVersion = flag.Bool("version", false, "show version and exit")
)

func main() {
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

	if *configPath == "" {
		return fmt.Errorf("--config_path must be set")
	}

	if *outputPath == "" {
		return fmt.Errorf("--output_path must be set")
	}

	var statePathsList []string
	for _, p := range strings.Split(*statePaths, ",") {
		p = strings.TrimSpace(p)
		if len(p) == 0 {
			break
		}
		statePathsList = append(statePathsList, p)
	}

	args := &policygen.RunArgs{
		ConfigPath: *configPath,
		StatePaths: statePathsList,
		OutputPath: *outputPath,
	}

	rn := &runner.Default{Quiet: true}
	if err := policygen.Run(context.Background(), rn, args); err != nil {
		return fmt.Errorf("failed to generate policies: %v", err)
	}

	return nil
}
