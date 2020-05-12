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

// StorageBucketIAMMember defines a struct with the necessary information for a google_storage_bucket_iam_member to be imported.
type StorageBucketIAMMember struct{}

// ImportID returns the ID of the resource to use in importing.
func (b *StorageBucketIAMMember) ImportID(rc terraform.ResourceChange, pcv ProviderConfigMap, interactive bool) (string, error) {
	bucket, err := fromConfigValues("bucket", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	role, err := fromConfigValues("role", rc.Change.After, pcv)
	if err != nil {
		return "", err
	}

	member, err := fromConfigValues("member", rc.Change.After, nil)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%v %v %v", bucket, role, member), nil
}
