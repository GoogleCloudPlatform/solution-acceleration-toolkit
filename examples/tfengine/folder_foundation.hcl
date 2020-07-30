# Copyright 2020 Google LLC
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

# {{$recipes := "../../templates/tfengine/recipes"}}

data = {
  parent_type     = "folder"
  parent_id       = "12345678"
  billing_account = "000-000-000"
  state_bucket    = "example-terraform-state"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location = "us-east1"
  cloud_sql_region  = "us-central1"
  compute_region    = "us-central1"
  storage_location  = "us-central1"
}

template "devops" {
  recipe_path = "{{$recipes}}/devops.hcl"
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to GCS.
    # enable_gcs_backend = true

    admins_group = "example-folder-admins@example.com"

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
    triggers = {
      validate = {}
      plan     = {}
      apply    = {}
    }

    build_viewers = [
      "group:example-cicd-viewers@example.com",
    ]

    managed_modules = [
      "devops", // NOTE: CICD service account can only update APIs on the devops project.
      "audit",
      "monitor",
      "org_policies",
      "folders",
    ]
  }
}

template "audit" {
  recipe_path = "{{$recipes}}/audit.hcl"
  output_path = "./audit"
  data = {
    auditors_group = "example-auditors@example.com"
    project = {
      project_id = "example-audit"
    }
    logs_bigquery_dataset = {
      dataset_id = "1yr_org_audit_logs"
    }
    logs_storage_bucket = {
      name = "7yr-org-audit-logs"
    }
  }
}

template "monitor" {
  recipe_path = "{{$recipes}}/monitor.hcl"
  output_path = "./monitor"
  data = {
    project = {
      project_id = "example-monitor"
    }
    forseti = {
      domain = "example.com"
    }
  }
}


# Subfolders.
template "folders" {
  recipe_path = "{{$recipes}}/folders.hcl"
  output_path = "./folders"
  data = {
    folders = [
      {
        display_name = "prod"
      },
      {
        display_name  = "team1"
        resource_name = "prod_team1" // Prevent name conflict with dev/team1.
        parent        = "$${google_folder.prod.name}"
      },
      {
        display_name  = "dev"
      },
      {
        display_name  = "team1"
        resource_name = "dev_team1" // Prevent name conflict with prod/team1.
        parent        = "$${google_folder.dev.name}"
      }
    ]
  }
}
