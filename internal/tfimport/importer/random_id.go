/*
 * Copyright 2021 Google LLC.
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
	base64 "encoding/base64"
	hex "encoding/hex"
	"fmt"
	"os"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// RandomID defines a struct with the necessary information for a random_id to be imported.
type RandomID struct{}

// ImportID returns the ID of the resource to use in importing.
func (c *RandomID) ImportID(rc terraform.ResourceChange, pcv ConfigMap, interactive bool) (string, error) {
	if !interactive {
		return "", &InsufficientInfoErr{MissingFields: []string{"b64_url"}}
	}

	// Ask the user for the random_id.
	prompt := "Please enter the previously-generated random_id, in *hex* form. See https://www.terraform.io/docs/providers/random/r/id.html#attributes-reference."
	idHex, err := fromUser(os.Stdin, "b64_url", prompt)
	if err != nil {
		return "", err
	}

	// Convert to base64.
	// Important: no padding, the import doesn't accept it with padding.
	b, err := hex.DecodeString(idHex)
	if err != nil {
		return "", err
	}
	b64 := base64.StdEncoding.WithPadding(base64.NoPadding).EncodeToString(b)

	// Need to import with prefix if present, otherwise without.
	prefix, err := fromConfigValues("prefix", rc.Change.After, pcv)
	if err == nil && prefix != nil {
		return fmt.Sprintf("%v,%v", prefix, b64), nil
	}
	return fmt.Sprintf("%v", b64), nil
}
