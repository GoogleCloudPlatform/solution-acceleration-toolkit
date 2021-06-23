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

package importer

import (
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// SimpleImporter defines a struct with the necessary information to import a resource that only depends on fields from the plan.
// Should be used by any resource that doesn't use interactivity, API calls, or complicated processing of fields.
type SimpleImporter struct {
	Fields   []string
	Tmpl     string
	Defaults map[string]interface{}
}

// ImportID returns the ID of the resource to use in importing.
func (i *SimpleImporter) ImportID(rc terraform.ResourceChange, pcv ConfigMap, interactive bool) (string, error) {
	// Get required fields.
	// The field will be looked up, in order, from:
	// * rc.Change.After - the values from a Terraform plan, representing the intended state after an apply.
	// * pcv - The provider config values from a Terraform plan. These are a typical fallback when a resource doesn't explicitly define i.e. the GCP project.
	// * i.Defaults - Manually provided defaults. Some resources have default values from the provider, i.e. the "namespace" field of helm_release.
	fieldsMap, err := loadFields(i.Fields, interactive, rc.Change.After, pcv, i.Defaults)
	if err != nil {
		return "", err
	}

	buf, err := template.WriteBuffer(i.Tmpl, fieldsMap)
	if err != nil {
		return "", err
	}
	return buf.String(), err
}
