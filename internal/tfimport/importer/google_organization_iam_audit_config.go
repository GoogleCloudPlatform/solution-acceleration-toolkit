/*
 * Copyright 2020 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package importer

import (
	"fmt"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// OrgIAMAuditConfig defines a struct with the necessary information for a GKE cluster to be imported.
type OrgIAMAuditConfig struct{}

// ImportID returns the GCP project and bucket name for use in importing.
func (b *OrgIAMAuditConfig) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap) (string, error) {
	orgID, err := fromConfigValues("org_id", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	service, err := fromConfigValues("service", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%v %v", orgID, service), nil
}
