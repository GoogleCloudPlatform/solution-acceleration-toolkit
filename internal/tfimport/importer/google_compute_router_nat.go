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

// ComputeRouterNat defines a struct with the necessary information for a google_container_cluster to be imported.
type ComputeRouterNat struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *ComputeRouterNat) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap) (string, error) {
	project, err := fromConfigValues("project", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	region, err := fromConfigValues("region", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	router, err := fromConfigValues("router", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	name, err := fromConfigValues("name", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("projects/%v/regions/%v/routers/%v/%v", project, region, router, name), nil
}
