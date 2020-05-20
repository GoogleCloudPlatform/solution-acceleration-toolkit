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

// ServiceAccountIAMBinding defines a struct with the necessary information for a google_service_account_iam_binding to be imported.
type ServiceAccountIAMBinding struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *ServiceAccountIAMBinding) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	// This already includes the project. It looks like this:
	// projects/my-network-project/serviceAccounts/my-sa@my-network-project.iam.gserviceaccount.com
	serviceAccountID, err := fromConfigValues("service_account_id", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%v roles/iam.serviceAccountUser", serviceAccountID), nil
}
