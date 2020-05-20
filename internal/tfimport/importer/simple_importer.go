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

package importer

import (
	"bytes"
	"fmt"
	"html/template"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// SimpleImporter defines a struct with the necessary information to import a resource that only depends on fields from the plan.
// Should be used by any resource that doesn't use interactivity, API calls, or complicated processing of fields.
type SimpleImporter struct {
	Fields []string
	Tmpl   string
}

func loadFields(fields []string, fieldsMap map[string]string, maps ...ProviderConfigMap) error {
	for _, field := range fields {
		val, err := fromConfigValues(field, maps...)
		if err != nil {
			return err
		}

		// A bit safer to use the printf string conversion than the type assertion (i.e. val.(string)).
		fieldsMap[field] = fmt.Sprintf("%s", val)
	}
	return nil
}

// ImportID returns the ID of the resource to use in importing.
func (i *SimpleImporter) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap) (string, error) {
	fieldsMap := make(map[string]string)

	// Get required fields.
	err := loadFields(i.Fields, fieldsMap, rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	// Build the template.
	buf := &bytes.Buffer{}
	tmpl, err := template.New("").Option("missingkey=error").Parse(i.Tmpl)
	if err != nil {
		return "", err
	}

	// Execute the template.
	err = tmpl.Execute(buf, fieldsMap)
	if err != nil {
		return "", err
	}

	return buf.String(), nil
}
