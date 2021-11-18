# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

template "root" {
  recipe_path = "./modules/root.hcl"
  data = {
    recipes          = "../../templates/tfengine/recipes"
    folder_id        = "12345678"
    billing_account  = "000-000-000"
    customer_id      = "c12345678"
    state_bucket     = "example-terraform-state"
    domain           = "example.com"
    prefix           = "example"
    env              = "prod"
    default_location = "us-central1"
    default_zone     = "a"
    labels = {
      env = "prod"
    }
  }
}
