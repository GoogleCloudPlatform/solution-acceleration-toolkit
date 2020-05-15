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

// ComputeSubnetworkIAM defines a struct with the necessary information for google_compute_subnetwork_iam_* resources to be imported.
type ComputeSubnetworkIAM struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *ComputeSubnetworkIAM) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap) (string, error) {
	// This is presented in the fully-qualified form. Example:
	// projects/my-network-project/regions/us-east1/subnetworks/gke-clusters-subnetwork
	subnetwork, err := fromConfigValues("subnetwork", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	// google_compute_subnetwork_iam_policy only takes the subnetwork
	importID := fmt.Sprintf("%v", subnetwork)

	// google_compute_subnetwork_iam_binding also takes a role
	role, err := fromConfigValues("role", rc.Change.After, nil)
	if err == nil {
		importID = fmt.Sprintf("%v %v", importID, role)
	}

	// google_compute_subnetwork_iam_member also takes a member
	member, err := fromConfigValues("member", rc.Change.After, nil)
	if err == nil {
		importID = fmt.Sprintf("%v %v", importID, member)
	}

	return importID, nil
}
