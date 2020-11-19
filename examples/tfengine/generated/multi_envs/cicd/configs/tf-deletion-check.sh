# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env bash

# Helper script that checks for delete changes in terraform plans.
# Expects that the following command was previously run:
# $ terraform plan -out=plan.tfplan
#
# Requirements:
#  * terraform
#  * jq
#
# Can optionally pass in a path to an allowlist file. It will be passed as an
# argument to `grep -Evf` to ignore certain resources for deletion. The
# patterns will be matched against the resource address.
# See https://en.wikipedia.org/wiki/Regular_expression#POSIX_extended

set -e

# Look for an allowlist of which resources are allowed to be deleted.
# Make sure it exists, is readable, and isn't empty.
allowlist="${1}"
if [[ -s "${allowlist}" && -r "${allowlist}" ]]; then
  allowlist_path="$(pwd)/${allowlist}"
  cat <<EOF
Using allowlist from ${allowlist_path}:
$(cat "${allowlist_path}")

EOF
fi

echo -e 'Checking for resource deletions...\n'

# Parse every plan
found_deletes="false"
for planfile in $(find "$(pwd)" -name 'plan.tfplan'); do
  plandir="$(dirname ${planfile})"
  pushd "${plandir}" &>/dev/null

  delchanges="$(terraform show -json $(basename ${planfile}) | jq -rM '.resource_changes[]? | select(.change.actions | index("delete")) | .address')"

  # Filter through the allowlist, if configured.
  # Removes any matching resources, so they are no longer considered.
  if [[ -n "${allowlist_path}" ]]; then
    delchanges="$(echo "${delchanges}" | grep -Evf "${allowlist_path}")"
  fi

  if ! [[ -z "${delchanges}" ]]; then
    cat >&2 <<EOF
Warning: Found changes intending to delete the following resources in module ${plandir}:
$(printf '\t%s\n' ${delchanges[@]})

EOF
    found_deletes="true"

    # Don't fail early, show all deletions found.
  fi

  popd &>/dev/null
done

if [[ "${found_deletes}" == 'true' ]]; then
  echo >&2 'Destructive changes should be reviewed carefully by a human operator before being applied by automation.'
else
  echo >&2 'No resource deletion found.'
fi
