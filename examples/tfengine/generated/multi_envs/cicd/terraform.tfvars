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

build_editors = [
  "group:example-cicd-editors@example.com",
]
build_viewers = [
  "group:example-cicd-viewers@example.com",
]
cloud_source_repostory = {
  name = "example"
  readers = [
    "group:example-source-readers@example.com",
  ]
  writers = [
    "group:example-source-writers@example.com",
  ]
}
billing_account = "000-000-000"
project_id      = "example-devops"
state_bucket    = "example-terraform-state"
