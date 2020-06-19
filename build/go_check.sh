# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash
set -e

# Print versions
go version

# Install more advanced linter.
# See https://golangci-lint.run/usage/install/#ci-installation
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin v1.27.0

# Check format
f=$(gofmt -l .)
if [[ "${f}" ]]; then
  echo "The following files are not formatted:"
  echo "${f}"
  exit 1
fi

go mod tidy
go build ./...
go vet ./...
golangci-lint run
go test ./...
