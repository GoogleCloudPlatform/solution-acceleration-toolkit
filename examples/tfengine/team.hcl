# Copyright 2020 Google LLC
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

# {{$recipes := "../../templates/tfengine/recipes"}}

data = {
  parent_type      = "folder"
  parent_id        = "12345678"
  billing_account  = "000-000-000"
  state_bucket     = "example-terraform-state"
  domain           = "example.com"
  prefix           = "example"
  env              = "prod"
  default_location = "us-central1"
  default_zone     = "a"
  storage_location = "us-central1"
  labels = {
    env = "prod"
  }
}

template "foundation" {
  recipe_path = "./modules/foundation.hcl"
  data = {
    recipes = "../{{$recipes}}"
  }
}

template "main" {
  recipe_path = "./modules/team.hcl"
  data = {
    recipes = "../{{$recipes}}"
  }
}
