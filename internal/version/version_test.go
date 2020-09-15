// Copyright 2020 Google LLC.
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

package version

import (
	"testing"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd"
)

// Minimal testing here, since it's almost entirely leveraging github.com/hashicorp/go-version, which has its own tests.
func TestCompatible(t *testing.T) {
	cases := []struct {
		binVersion      string
		templateVersion string
		want            bool
	}{
		// Empty versions.
		{
			binVersion:      "",
			templateVersion: "",
			want:            true,
		},
		{
			binVersion:      "1.2.3",
			templateVersion: "",
			want:            true,
		},
		{
			binVersion:      "",
			templateVersion: "1.2.3",
			want:            true,
		},

		// Equal.
		{
			binVersion:      "1.2.3",
			templateVersion: "1.2.3",
			want:            true,
		},

		// Different.
		{
			binVersion:      "1.2.4",
			templateVersion: "1.2.3",
			want:            true,
		},
		{
			binVersion:      "1.2.3",
			templateVersion: "1.2.4",
			want:            false,
		},

		// Same patch, no minor.
		{
			binVersion:      "1.2",
			templateVersion: "1.2.3",
			want:            false,
		},
		{
			binVersion:      "1.2.3",
			templateVersion: "1.2",
			want:            true,
		},

		// Latest
		{
			binVersion:      "latest",
			templateVersion: "99.99.99",
			want:            true,
		},
	}

	for _, tc := range cases {
		cmd.Version = tc.binVersion
		got, err := Compatible(tc.templateVersion)
		if err != nil {
			t.Errorf("TestCompatible(%v) with %v unexpectedly failed: %v", tc.templateVersion, tc.binVersion, err)
		}

		if got != tc.want {
			t.Errorf("TestCompatible(%v) with %v = %v; want %v", tc.templateVersion, tc.binVersion, got, tc.want)
		}
	}
}

func TestCompatibleMalformed(t *testing.T) {
	cases := []struct {
		version string
	}{
		{version: "-1"},
		{version: "all_text"},
		{version: ".1.2"},
		{version: "text-1.2.3"},
	}

	for _, tc := range cases {
		cmd.Version = tc.version
		_, err := Compatible(tc.version)
		if err == nil {
			t.Errorf("TestCompatible(%v) succeeded for malformed input, want error", tc.version)
		}
	}
}
