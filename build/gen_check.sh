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

#!/usr/bin/env bash
set -e

function test_gen() {
  local cmd="${1}"
  local reference_dir="${2}"
  shift 2

  # Generate in a tmp dir, then diff with examples.
  # Give the tmpdir a more meaningful name
  suffix="$(echo "${reference_dir}" | cut -d'/' -f2,4 --output-delimiter='-')"
  tmp="$(mktemp -d "/tmp/tmp-${suffix}.XXXXXX")"
  trap "rm -rf '${tmp}'" EXIT INT TERM RETURN ERR

  ${cmd} "${tmp}"

  # Don't use diff -x because that matches basenames in any directory.
  # We specifically want to exclude only the top-level README.md.
  changed="$(diff -qr ./${reference_dir} ${tmp} | grep -v ': README.md')" || true
  if [[ -n "${changed}" ]]; then
    cat <<EOF
The following generated files have changes:
${changed}

Please run the following command from the repo root and check in the changes:
./scripts/regen.sh
EOF
    exit 1
  fi
}


# Run the tests
test_gen 'go run ./cmd/policygen --config_path=examples/policygen/config.yaml --state_path examples/policygen/example.tfstate --output_path' 'examples/policygen/generated'
test_gen 'go run ./cmd/tfengine --config_path=examples/tfengine/org_foundation.hcl --output_path' 'examples/tfengine/generated/org_foundation'
test_gen 'go run ./cmd/tfengine --config_path=examples/tfengine/folder_foundation.hcl --output_path' 'examples/tfengine/generated/folder_foundation'
test_gen 'go run ./cmd/tfengine --config_path=examples/tfengine/full.hcl --output_path' 'examples/tfengine/generated/full'
