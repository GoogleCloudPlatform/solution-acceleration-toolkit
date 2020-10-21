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

# NOTE: This example is still under development and is not considered stable!
# Breaking changes to components for this example will not be part of releases.

template "app" {
  recipe_path = "../../templates/tfengine/recipes/app.hcl"
  data = {
    constants = {
      shared = {
        env_code        = "s"
        folder_id       = "123"
        billing_account = "000"
        project_prefix  = "example-prefix"
        state_bucket    = "example-state"
        region          = "us-central1"
      }
      dev = {
        env_code  = "d"
        folder_id = "456"
      }
    }
    devops = {
      admins_group = "admins@example.com"
      devops_owners = ["devops-owners-group@example.com"]
    }
    deployments = [
     {
       name = "project_networks",
     },
     {
       name = "project_data",
     },
     {
       name = "project_apps",
     },
    ]
  }
}
