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
// go run ./scripts/generate_schema_docs

package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
)

var (
	recipesDir = flag.String("recipes_dir", "templates/tfengine/recipes", "Directory hosting Terraform engine recipes.")
	outputDir  = flag.String("output_dir", "docs/tfengine/recipes", "Directory to output markdown files.")
)

var schemaRE = regexp.MustCompile(`(?s)(?:schema = {)(.+?)(?:}\n\n)`)

func main() {
	if err := run(*recipesDir, *outputDir); err != nil {
		log.Fatal(err)
	}
}

func run(recipesDir, outputDir string) error {
	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmp)

	fn := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if filepath.Ext(path) != ".hcl" {
			return nil
		}

		b, err := ioutil.ReadFile(path)
		if err != nil {
			return err
		}

		matches := schemaRE.FindSubmatch(b)
		if len(matches) == 0 {
			return nil
		}
		if len(matches) != 2 {
			return fmt.Errorf("unexpected number of matches: got %q, want 2", len(matches))
		}

		sj, err := hcl.ToJSON(matches[1])
		if err != nil {
			return err
		}

		s := new(schema)
		if err := json.Unmarshal(sj, s); err != nil {
			return err
		}

		buf := new(bytes.Buffer)
		if err := tmpl.Execute(buf, s); err != nil {
			return err
		}

		outPath := filepath.Join(outputDir, strings.Replace(info.Name(), ".hcl", ".md", 1))
		if err := ioutil.WriteFile(outPath, buf.Bytes(), 0755); err != nil {
			return fmt.Errorf("write %q: %v", outPath, err)
		}

		return nil
	}
	if err := filepath.Walk(recipesDir, fn); err != nil {
		return err
	}
	return nil
}
