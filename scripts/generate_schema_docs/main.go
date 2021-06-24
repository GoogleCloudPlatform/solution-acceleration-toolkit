// Copyright 2021 Google LLC
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

// Generates markdown files for schemas.
// Meant to be run from the repo root like so:
// go run ./scripts/generate_schema_docs

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/hcl"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/policygen"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
)

const (
	recipesDir = "./templates/tfengine/recipes"
	docsDir    = "./docs"
)

var schemaRE = regexp.MustCompile(`(?s)(?:schema = {)(.+?)(?:}\n\n)`)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	if err := writeSchema([]byte(tfengine.Schema), filepath.Join(docsDir, "tfengine/schemas/config.md")); err != nil {
		return err
	}
	if err := writeSchema([]byte(policygen.Schema), filepath.Join(docsDir, "policygen/schemas/config.md")); err != nil {
		return err
	}
	if err := generateRecipeSchemaDocs(); err != nil {
		return err
	}
	return nil
}

func generateRecipeSchemaDocs() error {
	outputDir := filepath.Join(docsDir, "tfengine/schemas")
	fn := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		matches, err := findMatches(path)
		if err != nil {
			return err
		}
		if len(matches) == 0 {
			return nil
		}

		outPath := filepath.Join(outputDir, strings.Replace(info.Name(), ".hcl", ".md", 1))

		return writeSchema(matches[1], outPath)
	}
	return filepath.Walk(recipesDir, fn)
}

// findMatches extracts the schema from an HCL recipe.
// Matches will be empty if there is no schema or the file is not HCL.
func findMatches(path string) ([][]byte, error) {
	if filepath.Ext(path) != ".hcl" {
		return nil, nil
	}

	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}

	matches := schemaRE.FindSubmatch(b)
	if l := len(matches); l != 0 && l != 2 {
		return nil, fmt.Errorf("unexpected number of matches: got %q, want 0 or 2", len(matches))
	}
	return matches, nil
}

func schemaFromHCL(b []byte) (*schema, error) {
	sj, err := hcl.ToJSON(b)
	if err != nil {
		return nil, err
	}

	s := new(schema)
	if err := json.Unmarshal(sj, s); err != nil {
		return nil, err
	}
	massageSchema(s)
	return s, nil
}

// massageSchema prepares the schema for templating.
func massageSchema(s *schema) {
	props := s.Properties
	s.Properties = make(map[string]*property, len(props))
	addRequiredByParent(props, requiredToMap(s.Required))
	flattenObjects(s, props, "")

	for _, prop := range s.Properties {
		prop.Description = strings.TrimSpace(lstrip(prop.Description))
	}
}

// addRequiredByParent traverses the schema and adds a requiredByParent
// flag indicating that field is listed as required at the previous level
func addRequiredByParent(props map[string]*property, requiredFieldsByParent map[string]bool) {
	for name, prop := range props {
		if _, ok := requiredFieldsByParent[name]; ok {
			prop.RequiredByParent = true
		}
		switch prop.Type {
		case "object":
			addRequiredByParent(prop.Properties, requiredToMap(prop.Required))
		case "array":
			addRequiredByParent(prop.Items.Properties, requiredToMap(prop.Items.Required))
		}
	}
}

// requiredToMap converts a required array to a map of booleans
func requiredToMap(required []string) map[string]bool {
	requiredMap := make(map[string]bool, len(required))
	for _, field := range required {
		requiredMap[field] = true
	}
	return requiredMap
}

// flattenObjects will add the properties of all objects to the top level schema.
func flattenObjects(s *schema, props map[string]*property, prefix string) {
	for name, prop := range props {
		name = prefix + name
		s.Properties[name] = prop
		switch prop.Type {
		case "object":
			flattenObjects(s, prop.Properties, name+".")
		case "array":
			prop.Type = fmt.Sprintf("array(%s)", prop.Items.Type)
			flattenObjects(s, prop.Items.Properties, name+".")
		}
	}
}

// lstrip trims left space from all lines.
func lstrip(s string) string {
	var b strings.Builder
	for _, line := range strings.Split(s, "\n\n") {
		b.WriteString(strings.TrimLeft(line, " "))
		b.WriteString("<br><br>")
	}
	result := b.String()
	result = strings.TrimRight(result, "<br>")
	return strings.ReplaceAll(result, "\n", "")
}

func writeSchema(b []byte, outPath string) error {
	s, err := schemaFromHCL(b)
	if err != nil {
		return err
	}

	buf := new(bytes.Buffer)
	if err := tmpl.Execute(buf, s); err != nil {
		return err
	}

	if err := ioutil.WriteFile(outPath, buf.Bytes(), 0755); err != nil {
		return fmt.Errorf("write %q: %v", outPath, err)
	}
	return nil
}
