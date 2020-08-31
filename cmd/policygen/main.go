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
	"log"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/policygen"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
)

var (
	configPath = flag.String("config_path", "", "Path to the Policy Generator config.")
	statePaths = flag.String("state_paths", "", "A comma-separated list of paths to Terraform states. Each entry can be a single local file, a local directory or a Google Cloud Storage bucket (gs://my-state-bucket). If a local directory or a bucket is given, then all .tfstate files will be read recursively.")
	outputPath = flag.String("output_path", "", "Path to output directory to write generated policies")
)

func main() {
	flag.Parse()

	if *configPath == "" {
		log.Fatal("--config_path must be set")
	}

	if *outputPath == "" {
		log.Fatal("--output_path must be set")
	}

	args := &policygen.RunArgs{
		ConfigPath: *configPath,
		StatePaths: *statePaths,
		OutputPath: *outputPath,
	}

	rn := &runner.Default{Quiet: true}
	if err := policygen.Run(context.Background(), rn, args); err != nil {
		log.Fatalf("Failed to generate policies: %v", err)
	}
}
