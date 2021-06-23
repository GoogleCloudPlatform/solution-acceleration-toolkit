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
	"fmt"
	"os"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
)

// RandomInteger defines a struct with the necessary information for a random_integer to be imported.
type RandomInteger struct{}

// ImportID returns the ID of the resource to use in importing.
func (c *RandomInteger) ImportID(rc terraform.ResourceChange, pcv ConfigMap, interactive bool) (string, error) {
	if !interactive {
		return "", &InsufficientInfoErr{MissingFields: []string{"result"}}
	}

	// We can get most of the values without the user.
	min, err := fromConfigValues("min", rc.Change.After)
	if err != nil {
		return "", err
	}
	max, err := fromConfigValues("max", rc.Change.After)
	if err != nil {
		return "", err
	}

	// Seed is optional.
	seed, seedErr := fromConfigValues("seed", rc.Change.After)
	seedExists := seedErr == nil

	// Ask the user for the result.
	prompt := "Please enter the generated integer as the value for \"result\""
	result, err := fromUser(os.Stdin, "result", prompt)
	if err != nil {
		return "", err
	}

	ret := fmt.Sprintf("%v,%v,%v", result, min, max)
	if seedExists {
		ret = fmt.Sprintf("%v,%v", ret, seed)
	}
	return ret, nil
}
