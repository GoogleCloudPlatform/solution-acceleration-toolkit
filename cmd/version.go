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

// Package cmd provides access to the embedded version of the binaries.
// Taken from https://github.com/AgentZombie/go-embed-version.
package cmd

import "fmt"

var (
	// Version is set at compile time with -ldflags "-X '<package>/cmd.Version=x.y.z'"
	// Example:
	//   go run -ldflags "-X 'github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd.Version=1.2.3'" ./cmd/tfengine -version
	Version = ""
	// BuildTime is set at compile time with -ldflags "-X '<package>/cmd.BuildTime=<date>'"
	// Example:
	//   go run -ldflags "-X 'github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd.BuildTime=Thu 17 Dec 2020 02:58:52 PM EST'" ./cmd/tfengine -version
	BuildTime = ""
)

// ShowVersion shows the version and the build time.
func ShowVersion() {
	fmt.Printf("%v (built on %v)\n", Version, BuildTime)
}
