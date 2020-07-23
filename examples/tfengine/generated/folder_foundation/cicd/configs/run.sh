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
set -x

DIRS=(
  audit
  monitor
  org_policies
  folders
)

ACTION="plan"
ROOT=""

while getopts 'a:p:' c
do
  case $c in
    a) ACTION=${OPTARG} ;;
    p) ROOT=${OPTARG} ;;
    *)
      echo "Invalid flag ${OPTARG}"
      exit 1
      ;;
  esac
done

for d in ${DIRS[@]}
do
    if [ -z "${ROOT}"]; then
      cd $d
    else
      cd $ROOT/$d
    fi
    terraform init
    terraform ${ACTION}
done
