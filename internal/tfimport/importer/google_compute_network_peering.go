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

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// ComputeNetworkPeering defines a struct with the necessary information for a google_compute_network_peering to be imported.
type ComputeNetworkPeering struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *ComputeNetworkPeering) ImportID(rc terraform.ResourceChange, pcv ConfigMap, interactive bool) (string, error) {
	// This is expected to be in the following format:
	// projects/my-network-project/global/networks/my_network
	// See https://github.com/terraform-providers/terraform-provider-google/blob/6649452bb9ab5ff995ba2eeca4e7efe83333da85/google/resource_compute_network_peering.go#L15
	network, err := fromConfigValues("network", rc.Change.After)
	if err != nil {
		return "", err
	}

	// Extract the project and network name.
	parts := strings.Split(fmt.Sprintf("%s", network), "/")
	project := parts[1]
	network_name := parts[4]

	name, err := fromConfigValues("name", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%v/%v/%v", project, network_name, name), nil

}
