# Copyright 2022 Google LLC
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
set -e

# Find all projects in specified folder over one day old.
projects=$(gcloud projects list --format="value(projectId)" \
--filter="parent.type=folder AND parent.id=${FOLDER_ID} AND createTime<=-P1D")

projects_array=(${projects})
echo "Found ${#projects_array[@]} projects over one day old."

for PROJECT in ${projects}
do
  echo "Removing liens in project: ${PROJECT}"
  for lien in $(gcloud alpha resource-manager liens list --project=${PROJECT} --format="value(name)")
  do
    gcloud alpha resource-manager liens delete ${lien}
  done
  echo "Deleting project: ${PROJECT}"
  gcloud projects delete ${PROJECT}
done
