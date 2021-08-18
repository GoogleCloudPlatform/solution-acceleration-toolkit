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

parent_id        = "12345678"
parent_type      = "folder"
billing_account  = "000-000-000"
project_id       = "example-devops"
scheduler_region = "us-east1"
state_bucket     = "example-terraform-state"
terraform_root   = "terraform"
build_editors    = ["group:example-cicd-editors@example.com"]

build_viewers = ["group:example-cicd-viewers@example.com"]

cloud_source_repository = {
  name = "example"
  readers = [
    "group:example-source-readers@example.com",
  ]
  writers = [
    "group:example-source-writers@example.com",
  ]
}
github = {
  owner = ""
  name  = ""
}
envs = [
  {
    branch_name  = "shared"
    managed_dirs = "groups audit folders"
    name         = "shared"
    triggers = {
      validate = {
        skip            = false
        run_on_push     = true
        run_on_schedule = ""
      }
      plan = {
        skip            = false
        run_on_push     = true
        run_on_schedule = ""
      }
      apply = {
        skip            = false
        run_on_push     = false
        run_on_schedule = ""
      }
    }
  },
  {
    branch_name  = "dev"
    managed_dirs = "dev/data"
    name         = "dev"
    triggers = {
      validate = {
        skip            = false
        run_on_push     = true
        run_on_schedule = ""
      }
      plan = {
        skip            = true
        run_on_push     = false
        run_on_schedule = ""
      }
      apply = {
        skip            = false
        run_on_push     = true
        run_on_schedule = ""
      }
    }
  },
  {
    branch_name  = "main"
    managed_dirs = "prod/data"
    name         = "prod"
    triggers = {
      validate = {
        skip            = false
        run_on_push     = true
        run_on_schedule = ""
      }
      plan = {
        skip            = false
        run_on_push     = true
        run_on_schedule = ""
      }
      apply = {
        skip            = false
        run_on_push     = false
        run_on_schedule = ""
      }
    }
  },
]
