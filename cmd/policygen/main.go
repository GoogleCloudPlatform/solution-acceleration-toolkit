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
	inputDir    = flag.String("input_dir", "", "Path to Terraform configs root directory. Cannot be specified together with other types of inputs.")
	inputPlan   = flag.String("input_plan", "", "Path to Terraform plan in json format, Cannot be specified together with other types of inputs.")
	inputState  = flag.String("input_state", "", "Path to Terraform state in json format. Cannot be specified together with other types of inputs.")
	outputDir   = flag.String("output_dir", "", "Path to directory to write generated policies")
)

func main() {
	flag.Parse()

	maxOneNonEmpty := func(ss ...string) bool {
		var n int
		for _, s := range ss {
			if s != "" {
				n++
			}
		}
		return n <= 1
	}

	if !maxOneNonEmpty(*inputDir, *inputPlan, *inputState) {
		log.Fatal("maximum one of --input_dir, --input_plan or --input_state must be specified")
	}

	if *inputConfig == "" {
		log.Fatal("--input_config must be set")
	}

	if *outputDir == "" {
		log.Fatal("--output_dir must be set")
	}

	if err := policygen.Run(*inputConfig, *inputDir, *inputPlan, *inputState, *outputDir); err != nil {
		log.Fatalf("Failed to generate policies: %v", err)
	}
}
