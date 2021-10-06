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
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to GCS.
    # enable_gcs_backend = true

    admins_group = {
      id     = "example-org-admins@example.com"
      exists = true
    }

    project = {
      project_id = "example-devops"
      owners_group = {
        id     = "example-devops-owners@example.com"
        exists = true
      }
    }
  }
}

# Must first be deployed manually before 'cicd' is deployed because some groups created
# here are used in 'cicd' template.
template "groups" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./groups"
  data = {
    project = {
      project_id = "example-devops"
      exists     = true
    }
    resources = {
      groups = [
        {
          id          = "example-cicd-viewers@example.com"
          customer_id = "c12345678"
        },
        {
          id          = "example-cicd-editors@example.com"
          customer_id = "c12345678"
        },
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

    # Required for scheduler.
    scheduler_region = "us-east1"

    build_viewers = ["group:example-cicd-viewers@example.com"]
    build_editors = ["group:example-cicd-editors@example.com"]

    terraform_root = "terraform"

    service_account = {
      id     = "cloudbuild-sa"
      exists = true
    }
    logs_bucket = "example-devops-cloudbuild-logs-bucket"

    envs = [
      {
        name        = "prod"
        branch_name = "main"
        # Prepare and enable default triggers.
        triggers = {
          validate = {}
          plan = {
            run_on_schedule = "0 12 * * *" # Run at 12 PM EST everyday
          }
          apply = {
            run_on_push = false # Do not auto run on push to branch
          }
        }
        managed_dirs = []
      }
    ]
  }
}
