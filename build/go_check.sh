# Copyright 2021 Google LLC
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

# Install golint.
# Switch directories to avoid changing go.mod and go.sum files (see https://stackoverflow.com/a/57313319).
(cd / && go install golang.org/x/lint/golint@latest)

# Check format
f=$(gofmt -l .)
if [[ "${f}" ]]; then
  echo "The following files are not formatted:"
  echo "${f}"
  echo 'To fix, run `gofmt .`'
  echo 'Diffs:'
  gofmt -d .
  exit 1
fi

go mod tidy
golangci-lint run
$GOPATH/bin/golint -set_exit_status ./...

go build ./...
go vet ./...
go test ./... -v
