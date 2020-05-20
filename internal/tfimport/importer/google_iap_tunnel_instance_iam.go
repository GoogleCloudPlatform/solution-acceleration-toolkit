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

// IAPTunnerInstanceIAMPolicy defines a struct with the necessary information for a google_iap_tunnel_instance_iam_policy to be imported.
type IAPTunnerInstanceIAMPolicy struct{}

// IAPTunnerInstanceIAMBinding defines a struct with the necessary information for a google_iap_tunnel_instance_iam_binding to be imported.
type IAPTunnerInstanceIAMBinding struct{}

// IAPTunnerInstanceIAMBinding defines a struct with the necessary information for a google_iap_tunnel_instance_iam_member to be imported.
type IAPTunnerInstanceIAMMember struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *IAPTunnerInstanceIAMPolicy) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	project, err := fromConfigValues("project", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	zone, err := fromConfigValues("zone", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	instance, err := fromConfigValues("instance", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("projects/%v/iap_tunnel/zones/%v/instances/%v", project, zone, instance), nil
}

func (b *IAPTunnerInstanceIAMBinding) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	project, err := fromConfigValues("project", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	zone, err := fromConfigValues("zone", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	instance, err := fromConfigValues("instance", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	role, err := fromConfigValues("role", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("projects/%v/iap_tunnel/zones/%v/instances/%v %v", project, zone, instance, role), nil
}

func (b *IAPTunnerInstanceIAMMember) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	project, err := fromConfigValues("project", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	zone, err := fromConfigValues("zone", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	instance, err := fromConfigValues("instance", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	role, err := fromConfigValues("role", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	member, err := fromConfigValues("member", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("projects/%v/iap_tunnel/zones/%v/instances/%v %v %v", project, zone, instance, role, member), nil
}
