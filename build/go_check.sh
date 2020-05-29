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

# Check format
f=$(gofmt -l .)
if [[ "${f}" ]]; then
  echo "The following files are not formatted:"
  echo "${f}"
  exit 1
fi

changes=false

# Check dependencies up-to-date
# It's okay to remove go.sum, it gets regenerated, and this way it removes unnecessary sums.
cp go.mod go.mod.prev
mv go.sum go.sum.prev
go mod download
go get -u ./...
go mod tidy
go_mod_diff=$(diff -u go.mod go.mod.prev) || true
if [[ "${go_mod_diff}" ]]; then
  changes=true
  cat <<EOF

go.mod has changes:
${go_mod_diff}

EOF
fi
rm go.mod.prev

# Check go.sum as well
go_sum_diff=$(diff -u go.sum go.sum.prev) || true
if [[ "${go_sum_diff}" ]]; then
  changes=true
  cat <<EOF

go.sum has changes:
${go_sum_diff}

EOF
fi
rm go.sum.prev

if [ "${changes}" = true ]; then
  echo "Please run 'go get -u ./...' locally and commit the changes."
  exit 1
fi

go vet ./...
go build ./...
go test ./...
