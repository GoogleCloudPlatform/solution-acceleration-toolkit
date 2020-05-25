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
// $ policygen --input_config=./samples/config.yaml --output_dir=/tmp/constraints {--input_dir=/path/to/configs/dir|--input_plan=/path/to/plan/json|--input_state=/path/to/state/json}
package main

import (
	"flag"
	"log"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/policygen"
)

var (
	inputConfig = flag.String("input_config", "", "Path to the Policy Generator config.")
	inputState  = flag.String("input_state", "", "Path to Terraform state in json format.")
	outputDir   = flag.String("output_dir", "", "Path to directory to write generated policies")
)

func main() {
	flag.Parse()

	if *inputConfig == "" {
		log.Fatal("--input_config must be set")
	}

	if *outputDir == "" {
		log.Fatal("--output_dir must be set")
	}

	args := &policygen.RunArgs{
		InputConfig: *inputConfig,
		InputState:  *inputState,
		OutputDir:   *outputDir,
	}

	if err := policygen.Run(args); err != nil {
		log.Fatalf("Failed to generate policies: %v", err)
	}
}
