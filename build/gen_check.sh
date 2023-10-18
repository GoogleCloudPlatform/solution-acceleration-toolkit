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

# This file ensures that the checked-in generated examples are up-to-date.

#!/usr/bin/env bash
set -e

# Copy the current examples dir
tmp="$(mktemp -d "/tmp/tmp-gen_check.XXXXXX")"
trap "rm -rf '${tmp}'" EXIT INT TERM RETURN ERR
cp -ar './examples/' "${tmp}"

# Regenerate examples into the tmp dir
./scripts/regen.sh "${tmp}/examples"

# Check for diffs
changed="$(diff -c "${tmp}/examples" "./examples" | grep -v ': README.md')" || true
if [[ -n "${changed}" ]]; then
  cat <<EOF
${changed}

Please run the following command from the repo root and check in the changes:
./scripts/regen.sh
EOF
  exit 1
fi
