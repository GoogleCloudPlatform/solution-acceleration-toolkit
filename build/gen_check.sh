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

# This file ensures that the checked-in generated examples are up-to-date.

#!/bin/bash
set -e

# Print versions
go version

# Check format
if ! git -C . rev-parse; then
  # Not a git repo, init and add all files.
  echo 'Not a git repo, initializing and adding all files'
  git init
  git add .
  git commit -a --allow-empty-message -m ''
fi

# Generate files and check for changes.
cmd='go run ./cmd/policygen --config_path=examples/policygen/config.yaml --state_path=examples/policygen/example.tfstate --output_path=examples/policygen/generated'
${cmd}
changed="$(git diff-index --name-only HEAD)"
if [[ -n "${changed}" ]]; then
  cat <<EOF
The following generated files have changes:
${changed}

Please run ${cmd} and check in the changes.
EOF
  exit 1
fi
