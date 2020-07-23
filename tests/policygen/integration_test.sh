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

# Integration test for Policy Generator using CFT Scorecard and fake CAI data.

#!/bin/bash

set -e

tmp="$(mktemp -d "/tmp/xingao-tmp.XXXXXX")"
trap "rm -rf '${tmp}'" EXIT INT TERM RETURN ERR

# Install a fixed version of CFT tool. Output generated can be different from version to version.
curl -s -o ${tmp}/cft https://storage.googleapis.com/cft-cli/v0.3.4/cft-linux-amd64
chmod +x ${tmp}/cft

# Regenerate policies to a tmp location.
go run ./cmd/policygen --config_path examples/policygen/config.hcl --output_path ${tmp}/generated --state_path examples/policygen/example.tfstate

# Run CFT Scorecard. scorecard.csv is hardcoded in CFT Scorecard as the output file name.
output_file="${tmp}/scorecard.csv"
touch ${output_file}
${tmp}/cft scorecard --policy-path ${tmp}/generated/forseti_policies --dir-path tests/policygen/assets --output-format csv --output-path ${tmp}

# Sort the output file without the CSV header line.
LC_ALL=C sort -o ${output_file} <(tail -n+2 ${output_file})

changed="$(diff -u tests/policygen/reports/want_report.csv ${output_file})" || true
if [[ -n "${changed}" ]]; then
    cat <<EOF

FAIL

Generated report differs from wanted report:

${changed}
EOF
    exit 1
fi

echo "PASS"
