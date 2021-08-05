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


project_id = "example-data-prod"

parent_type = "folder"

parent_id = data.terraform_remote_state.folders.outputs.folder_ids["prod"]

billing_account = "000-000-000"

apis = ["compute.googleapis.com"]

is_shared_vpc_host = true


shared_vpc_attachment = {
  host_project_id = ""
  subnets = [
  ]
}
