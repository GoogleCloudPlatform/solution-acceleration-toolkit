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

output "folder_ids" {
  value = {
    prod       = google_folder.prod.folder_id
    prod_team1 = google_folder.prod_team1.folder_id
    dev        = google_folder.dev.folder_id
    dev_team1  = google_folder.dev_team1.folder_id
  }
}
