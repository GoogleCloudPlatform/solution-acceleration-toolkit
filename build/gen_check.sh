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

# Generate in a tmp dir, then diff with examples.
tmp="$(mktemp -d)"
trap "rm -rf '${tmp}'" EXIT INT TERM RETURN ERR
examples='examples/policygen/generated'

cmd='go run ./cmd/policygen --config_path=examples/policygen/config.yaml --state_path examples/policygen/example.tfstate --output_path'
${cmd} "${tmp}"

changed="$(diff -r ./${examples} ${tmp})" || true
if [[ -n "${changed}" ]]; then
  cat <<EOF
The following generated files have changes:
${changed}

Please run the following command and check in the changes:
${cmd} ${examples}
EOF
  exit 1
fi
