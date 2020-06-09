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

# Install CFT tool.
# TODO(xingao): add to CFT dev tools container.
curl -s -o ${tmp}/cft https://storage.googleapis.com/cft-cli/latest/cft-linux-amd64
chmod +x ${tmp}/cft

# Package policies.
root="$(git rev-parse --show-toplevel)"
${root}/scripts/package_policies.sh -s ${root}/examples/policygen/generated/forseti_policies -d ${tmp}

# Run CFT Scorecard.
touch ${tmp}/scorecard.csv
${tmp}/cft scorecard --policy-path ${tmp} --dir-path ${root}/tests/policygen/assets --output-format csv --output-path ${tmp}

changed="$(diff ${root}/tests/policygen/reports/want_report.csv ${tmp}/scorecard.csv)" || true
if [[ -n "${changed}" ]]; then
    cat <<EOF

FAIL

Generated report differs from wanted report:

${changed}
EOF
    exit 1
fi

echo "PASS"
