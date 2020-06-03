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
	"fmt"
	"strings"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// ResourceManagerLien defines a struct with the necessary information for a google_resource_manager_lien to be imported.
type ResourceManagerLien struct{}

// ImportID returns the ID of the resource to use in importing.
func (i *ResourceManagerLien) ImportID(rc terraform.ResourceChange, pcv ConfigMap, interactive bool) (string, error) {
	// Get required fields.
	fieldsMap, err := loadFields([]string{"parent", "name"}, interactive, rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	// Parent is in the form "project/1234567890", but we need to drop the prefix.
	parts := strings.Split(fmt.Sprintf("%s", fieldsMap["parent"]), "/")
	fieldsMap["parent"] = parts[len(parts)-1]

	buf, err := template.WriteBuffer("{{.parent}}/{{.name}}", fieldsMap)
	if err != nil {
		return "", err
	}
	return buf.String(), err
}
