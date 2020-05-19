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

// ServiceNetworkingConnection defines a struct with the necessary information for a google_service_networking_connection to be imported.
type ServiceNetworkingConnection struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *ServiceNetworkingConnection) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap) (string, error) {
	vnetwork, err := fromConfigValues("network", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	// The network comes in URL form, like this:
	// https://www.googleapis.com/compute/v1/projects/heroes-hat-dev-networks/global/networks/private
	// Parse out the ID part.
	network := vnetwork.(string)
	network = network[strings.Index(network, "project"):]

	service, err := fromConfigValues("service", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%v:%v", network, service), nil
}
