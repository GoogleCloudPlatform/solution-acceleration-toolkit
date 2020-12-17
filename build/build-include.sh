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

# Meant to be sourced in other build scripts, not used standalone.

set -e

OUTPUT_DIR="."
VERSION=""
SUPPORTED_OS=("linux" "darwin" "windows")
SUPPORTED_ARCH=("amd64")

while getopts 'o:v:' opt; do
  case ${opt} in
    o) OUTPUT_DIR=${OPTARG} ;;
    v) VERSION=${OPTARG} ;;
    *) echo "Invalid flag ${OPTARG}"
       exit 1
       ;;
  esac
done

if [[ -z ${VERSION} ]]; then
  echo "-v must be set"
  exit 1
fi

version_regex="^(latest|v[0-9]+\.[0-9]+\.[0-9]+)$"
if ! [[ ${VERSION} =~ ${version_regex} ]]; then
  echo "Version \"${VERSION}\" does not match regex ${version_regex}"
  exit 1
fi

# Functions to build different artifacts.
function build_binaries() {
  BUILD_TIME=$(date)

  for OS in "${SUPPORTED_OS[@]}"; do
    for ARCH in "${SUPPORTED_ARCH[@]}"; do
      for build_dir in $(find './cmd' -mindepth 1 -maxdepth 1 -type d); do
        bin_name="$(basename ${build_dir})"
        bin="${bin_name}_${VERSION}_${OS}-${ARCH}"
        echo "Building ${OUTPUT_DIR}/${bin}"
        env GOOS="${OS}" GOARCH="${ARCH}" go build -ldflags="-X 'github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd.Version=${VERSION}' -X 'github.com/GoogleCloudPlatform/healthcare-data-protection-suite/cmd.BuildTime=${BUILD_TIME}'" -o "${OUTPUT_DIR}/${bin}" "${build_dir}"
      done
    done
  done
}

function build_templates() {
  echo 'Bundling Engine templates'
  tar -czf "${OUTPUT_DIR}/templates_${VERSION}.tar.gz" "templates/tfengine"
}

function build_policies() {
  echo 'Bundling Policygen policies'
  tar -czf "${OUTPUT_DIR}/policies_${VERSION}.tar.gz" "templates/policygen"
}
