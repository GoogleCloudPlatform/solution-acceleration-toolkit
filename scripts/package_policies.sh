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

#!/bin/bash

set -e

# https://github.com/forseti-security/policy-library repo constants
COMMIT=f30bf774fb914959a9a18c132947eae95543001e
SHA256=df40ad1133c3d48e9c34066b03d93ee08a15f134c8dcdce750ba36ba06cb4c84

while getopts ":s:d:" opt; do
  case $opt in
    s)
      src="$OPTARG"
    ;;
    d)
      dst="$OPTARG"
    ;;
    \?)
        echo "Invalid option -$OPTARG"
        echo "usage: [-s source path] [-d destination path (use gs:// prefix for GCS bucket)]"
        exit 1
    ;;
  esac
done

if [[ -z ${src} ]]; then
  echo "Please supply the path to a local directory where the generated policies are located."
  exit 1
fi

if [[ -z ${dst} ]]; then
  echo "Please supply a destination to save the policies with rego templates and helper functions. 'gs://' prefix indicates a remote destination."
  exit 1
fi

tmp="$(mktemp -d "/tmp/xingao-tmp.XXXXXX")"
trap "rm -rf '${tmp}'" EXIT INT TERM RETURN ERR

# Download policy templates and rego helper functions needed for the policies to be consumed.
wget -q https://github.com/forseti-security/policy-library/archive/${COMMIT}.zip -P ${tmp}
echo "${SHA256} ${tmp}/${COMMIT}.zip" | sha256sum -c --quiet
unzip -q ${tmp}/${COMMIT}.zip -d ${tmp} policy-library-${COMMIT}/lib/* policy-library-${COMMIT}/policies/*

# Copy policies.
local=${tmp}/policy-library-${COMMIT}
cp -r ${src}/* ${local}/policies/constraints/

if [[ ${dst} == gs://* ]]; then
  echo "Uploading policies with templates to Google Cloud Storage. Make sure you have roles/storage.objectAdmin permission..."
  gsutil -m rsync -d -r ${local}/policies ${dst}/policy-library/policies
  gsutil -m rsync -d -r ${local}/lib ${dst}/policy-library/lib
else
  echo "Saving policies with templates to local directory..."
  mkdir -p ${dst}
  cp -r ${local}/* ${dst}
fi
