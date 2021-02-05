#!/bin/bash

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

set -ex

DIRS=()

while getopts "d:" c
do
  case $c in
    d) DIRS="${OPTARG}" ;;
    *)
      echo "Invalid flag ${OPTARG}"
      exit 1
      ;;
  esac
done

ROOT=$(realpath .)
# Read DIRS from a space-separated string to list
IFS=' ' read -r -a DIRS <<< "${DIRS}"

for mod in "${DIRS[@]}"
do
    cd "${ROOT}"/"${mod}"
    terraform init
    terraform plan -out=plan.tfplan
    project_id=$(terraform show -json plan.tfplan | jq -rM '.resource_changes[]? | select(.change.actions | index("create")) | select(.address | index("module.project.module.project-factory.google_project.main")) | .change.after.project_id')
    if ! [[ -z "${project_id}" ]]; then
      terraform import module.project.module.project-factory.google_project.main ${project_id} | true
    fi
    rm -rf .terraform* plan.tfplan
done
