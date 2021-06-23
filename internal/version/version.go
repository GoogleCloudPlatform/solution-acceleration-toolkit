// Copyright 2021 Google LLC
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

// Package version provides functions to check version compatibility between templates and binaries.
package version

import (
	"fmt"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/hashicorp/go-version"
)

// IsCompatible returns whether the given string version constraint is compatible with the binary version.
// Compatibility is determined by github.com/hashicorp/go-version.
// It returns an error if the constraint string or binary version cannot be interpreted.
func IsCompatible(constraint string) (bool, error) {
	// If either version is unspecified, it's compatible with all.
	// Think of it as not setting a compatibility restriction at all.
	if constraint == "" || cmd.Version == "" {
		return true, nil
	}

	// If the bin version is the special "latest", it always succeeds.
	// By definition there isn't a newer version.
	if cmd.Version == "latest" {
		return true, nil
	}

	binVersion, err := version.NewVersion(cmd.Version)
	if err != nil {
		return false, fmt.Errorf("interpreting binary version %q: %v", cmd.Version, err)
	}

	templateConstraint, err := version.NewConstraint(constraint)
	if err != nil {
		return false, fmt.Errorf("interpreting template version constraint %q: %v", templateConstraint, err)
	}

	return templateConstraint.Check(binVersion), nil
}
