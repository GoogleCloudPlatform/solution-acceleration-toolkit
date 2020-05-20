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

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// SQLUser defines a struct with the necessary information for a google_sql_user to be imported.
type SQLUser struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *SQLUser) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap) (string, error) {
	project, err := fromConfigValues("project", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	instance, err := fromConfigValues("instance", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	name, err := fromConfigValues("name", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	// Host is only used for MySQL.
	host, err := fromConfigValues("host", rc.Change.After, nil)
	if err == nil {
		return fmt.Sprintf("%v/%v/%v/%v", project, instance, host, name), nil
	}

	// If no host, use only the instance (PostgreSQL).
	return fmt.Sprintf("%v/%v/%v", project, instance, name), nil

}
