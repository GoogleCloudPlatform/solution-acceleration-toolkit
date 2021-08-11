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
admins_group = {
  customer_id  = "c12345678"
  description  = ""
  display_name = "Example Folder Admins Group"
  exists       = false
  id           = "example-folder-admins@example.com"
  owners = [
    "user1@example.com",
  ]
  managers = [
  ]
  members = [
  ]
}
billing_account = "000-000-000"
parent_id       = "12345678"
project = {
  apis = [
    "cloudbuild.googleapis.com",
    "cloudidentity.googleapis.com",
  ]
  owners_group = {
    customer_id  = "c12345678"
    description  = ""
    display_name = "example-devops-owners"
    exists       = false
    id           = "example-devops-owners@example.com"
    owners = [
      "user1@example.com",
    ]
    managers = [
    ]
    members = [
    ]
  }
  project_id = "example-devops"
}
storage_location = "us-central1"
state_bucket     = "example-terraform-state"
