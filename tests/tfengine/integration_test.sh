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

set -ex

DIRS=(project_secrets project_networks)

tmp="$(mktemp -d "/tmp/dps-tmp.XXXXXX")"
trap "rm -rf ${tmp}" EXIT INT TERM RETURN ERR

cat <<EOF >> ${tmp}/config.hcl
template "main" {
  recipe_path = "${PWD}/examples/tfengine/common/team.hcl"
  data = {
      prefix = "dpstest-$(date +%s)"
  }
}
EOF

go run ./cmd/tfengine --config_path ${tmp}/config.hcl --output_path ${tmp}/generated

set +e

# Apply the directories. Don't continue if one dir fails.
for i in ${!DIRS[@]}; do
  cd ${tmp}/generated/${DIRS[$i]}
  terraform init
  terraform apply -auto-approve
  rc=$?
  if [[ ${rc} -ne 0 ]]; then
    # Destroy this dir to clean up partial deployments.
    terraform destroy -auto-approve
    break
  fi
done

# Destroy the directories in reverse order.
for ((j=$i-1; j>=0; j--)); do
  cd ${tmp}/generated/${DIRS[$j]}
  terraform destroy -auto-approve
done

set -e

exit ${rc}
