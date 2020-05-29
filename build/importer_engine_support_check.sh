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

#!/usr/bin/env bash

set -e

# This is meant to be run from the root.
wd="$(pwd)"

# Create a temporary directory to avoid messing with local files, and delete it on exit.
tmp=$(mktemp -d)
trap "rm -rf '${tmp}'" EXIT INT TERM RETURN ERR

# Generate the full config with the engine.
config="${wd}/examples/tfengine/full.hcl"
echo "Generating configs from ${config}"
go run ./cmd/tfengine --config_path="${config}" --output_path="${tmp}"

# Convert all backends to local, not gcs.
# Uses perl for multiline string matching.
# See https://askubuntu.com/a/533268
echo 'Converting backends to "local"'
grep -Rl 'backend "gcs"' "${tmp}" | xargs perl -i -p0e 's/backend "gcs" {.*?}/backend "local" {}/s'

# Init all modules.
echo 'Running inits'
find "${tmp}" -name "main.tf" | while read f; do
  (cd $(dirname ${f}) && terraform init &>/dev/null)
done

# These are not importable by the provider.
unimportable=('google_bigquery_dataset_access' 'google_service_account_key' 'google_storage_bucket_object' 'local_file' 'null_resource' 'random_password' 'random_pet' 'random_shuffle' 'random_string' 'tls_private_key')

# Find all unsupported resource types.
echo 'Unsupported resources:'
grep -IRoh 'resource ".*' "${tmp}" | cut -d'"' -f2 | sort -u | while read resource; do
  # Skip supported or unimportable resources
  if grep -q "${resource}" "${wd}/internal/tfimport/tfimport.go" || [[ " ${unimportable[@]} " =~ " ${resource} " ]]; then
    continue
  fi
  echo "* ${resource}"
done
