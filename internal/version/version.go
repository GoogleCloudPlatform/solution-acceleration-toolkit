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

	"github.com/hashicorp/go-version"
)

// Compatible returns whether v1 and v2 are not compatible.
// Versions are compatible if v1 <= v2 as determined by github.com/hashicorp/go-version.
// It returns an error if the version strings cannot be interpreted as versions.
func Compatible(v1s, v2s string) (bool, error) {
	v1, err := version.NewVersion(v1s)
	if err != nil {
		return false, fmt.Errorf("converting %v to version: %v", v1s, err)
	}

	v2, err := version.NewVersion(v2s)
	if err != nil {
		return false, fmt.Errorf("converting %v to version: %v", v2s, err)
	}

	return v1.LessThanOrEqual(v2), nil
}
