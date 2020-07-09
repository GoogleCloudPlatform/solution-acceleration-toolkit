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
  parent_type      = "organization" # One of `organization` or `folder`.
  parent_id        = "12345678"
  billing_account  = "000-000-000"
  state_bucket     = "example-terraform-state"
  storage_location = "us-central1"
}

template "devops" {
  recipe_path = "{{$recipes}}/devops.hcl"
  output_path = "./bootstrap"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated bootstrap module has been deployed.
    # Run `terraform init` in the bootstrap module to backup its state to GCS.
    # enable_bootstrap_gcs_backend = true

    admins_group = "example-org-admins@example.com"

    project = {
      project_id = "example-devops"
      owners = [
        "group:example-devops-owners@example.com",
      ]
    }
  }
}

template "cicd" {
  recipe_path = "{{$recipes}}/cicd.hcl"
  output_path = "./cicd"
  data = {
    project_id = "example-devops"
    github = {
      owner = "GoogleCloudPlatform"
      name  = "example"
    }
    branch_regex   = "^master$"
    terraform_root = "terraform"

    # Prepare and enable default triggers.
    validate_trigger = {}
    plan_trigger     = {}
    apply_trigger    = {}
    build_viewers = [
      "group:example-cicd-viewers@example.com",
    ]
  }
}
