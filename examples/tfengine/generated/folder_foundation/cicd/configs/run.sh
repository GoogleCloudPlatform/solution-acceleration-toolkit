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

set -ex

ACTIONS=()
DIRS=()
ROOT="."

# TODO(https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/issues/1029): Remove this after CICD container is updated to the latest.
LATEST_GCLOUD_VERSION=356.0.0

apk add --no-cache curl
gcloud components update --version $LATEST_GCLOUD_VERSION

while getopts "a:d:r:" c
do
  case $c in
    a) ACTIONS+=("${OPTARG}") ;;
    d) DIRS="${OPTARG}" ;;
    r) ROOT="${OPTARG}" ;;
    *)
      echo "Invalid flag ${OPTARG}"
      exit 1
      ;;
  esac
done

ROOT=$(realpath "${ROOT}")
# Read DIRS from a space-separated string to list
IFS=' ' read -r -a DIRS <<< "${DIRS}"

for mod in "${DIRS[@]}"
do
    cd "${ROOT}"/"${mod}"
    for action in "${ACTIONS[@]}"
    do
      # Convert action string to array as it can have multiple arguments.
      IFS=' ' read -r -a args <<< "${action}"
      terraform "${args[@]}"
    done
done
