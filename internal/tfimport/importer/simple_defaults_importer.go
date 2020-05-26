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
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// SimpleDefaultsImporter defines a struct with the necessary information to import a resource that only depends on fields from the plan.
// Should be used when SimpleImporter almost works, but some fields have acceptable default values.
type SimpleDefaultsImporter struct {
	SimpleImporter
	Defaults map[string]interface{}
}

// ImportID returns the ID of the resource to use in importing.
func (i *SimpleDefaultsImporter) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	// Get required fields.
	fieldsMap, err := loadFields(i.Fields, interactive, rc.Change.After, pcv, i.Defaults)
	if err != nil {
		return "", err
	}

	return fillTemplate(i.Tmpl, fieldsMap)
}
