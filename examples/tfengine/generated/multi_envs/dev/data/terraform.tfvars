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


project_id = "example-data-dev"

parent_type = "folder"

parent_id = data.terraform_remote_state.folders.outputs.folder_ids["dev"]

billing_account = "000-000-000"

apis = ["compute.googleapis.com"]



shared_vpc_attachment = {
  host_project_id = "<no value>"
  subnets = [
  ]
}
