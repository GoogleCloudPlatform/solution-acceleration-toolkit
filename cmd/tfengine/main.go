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

// tfengine provides an engine to power your Terraform environment.
//
// Usage:
// $ tfengine --config_path=path/to/config --output_dir=/tmp/engine
package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
)

var (
	configPath  = flag.String("config_path", "", "Path to config file")
	outputPath  = flag.String("output_path", "", "Path to directory dump output")
	format      = flag.Bool("format", true, "Whether to format generated files.")
	templates   = flag.String("templates", "", "Comma-separated list of templates to generate. Leave empty for all.")
	addLicenses = flag.Bool("add_licenses", true, "Whether to add license headers to generated Terraform files.")
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

	cacheDir, err := ioutil.TempDir("", "")
	if err != nil {
		return fmt.Errorf("create temp dir: %v", err)
	}
	defer os.RemoveAll(cacheDir)

	wantedTemplates := make(map[string]bool)
	for _, t := range strings.Split(*templates, ",") {
		t = strings.TrimSpace(t)
		if len(t) > 0 {
			wantedTemplates[t] = true
		}
	}

	opts := &tfengine.Options{
		Format:          *format,
		AddLicenses:     *addLicenses,
		CacheDir:        cacheDir,
		WantedTemplates: wantedTemplates,
	}

	return tfengine.Run(*configPath, *outputPath, opts)
}
