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

// Package version provides functions to check version compatibility between templates and binaries.
package version

import (
	"fmt"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
	"github.com/hashicorp/go-version"
)

// Compatible returns whether the given string version is compatible with the binary version.
// Versions are compatible if v1 <= v2 as determined by github.com/hashicorp/go-version.
// It returns an error if the version string or binary version cannot be interpreted as versions.
func Compatible(vs string) (bool, error) {
	// If either version is unspecified, it's compatible with all.
	// Think of it as not setting a compatibility restriction at all.
	if vs == "" || cmd.Version == "" {
		return true, nil
	}

	// If the bin version is the special "latest", it always succeeds.
	// By definition there isn't a newer version.
	if cmd.Version == "latest" {
		return true, nil
	}

	binV, err := version.NewVersion(cmd.Version)
	if err != nil {
		return false, fmt.Errorf("converting binary version %q to version: %v", cmd.Version, err)
	}

	templateV, err := version.NewVersion(vs)
	if err != nil {
		return false, fmt.Errorf("converting template version %q to version: %v", vs, err)
	}

	return binV.GreaterThanOrEqual(templateV), nil
}
