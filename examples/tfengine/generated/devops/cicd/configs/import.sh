#!/bin/bash

# Copyright 2021 Google LLC
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

set -e

DIRS=()

while getopts "d:" c
do
  case $c in
    d) DIRS="${OPTARG}" ;;
    *)
      echo "Usage: import.sh -d=\"dir1 dir2 ...\""
      exit 1
      ;;
  esac
done

ROOT=$(realpath .)
# Read DIRS from a space-separated string to list
IFS=' ' read -r -a DIRS <<< "${DIRS}"

VERSION=v0.8.0
wget -q -O ${ROOT}/tfimport https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/download/${VERSION}/tfimport_${VERSION}_linux-amd64
chmod +x ${ROOT}/tfimport

for mod in "${DIRS[@]}"
do
  ${ROOT}/tfimport --input_dir="${ROOT}"/"${mod}" \
    --resource_types='google_project' \
    --resource_types='google_project_service' \
    --resource_types='google_service_account' \
    --interactive=false || true
done

rm -f ${ROOT}/tfimport
