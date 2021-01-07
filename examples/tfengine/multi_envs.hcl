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

    admins_group = {
      id = "example-folder-admins@example.com"
      display_name = "Example Folder Admins Group"
      customer_id = "c12345678"
      owners = [
        "user1@example.com"
      ]
    }

    project = {
      project_id = "example-devops"
      owners_group = {
        id = "example-devops-owners@example.com"
        customer_id = "c12345678"
        // No owner specified. The caller will be added as the default owner of the group.
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
          id = "example-auditors@example.com"
          customer_id = "c12345678"
          display_name = "Example Auditors Group"
          owners = [
            "user1@example.com"
          ]
          members = [
            "user2@example.com"
          ]
        },
        {
          id = "example-cicd-viewers@example.com"
          customer_id = "c12345678"
        },
        {
          id = "example-cicd-editors@example.com"
          customer_id = "c12345678"
        },
        {
          id = "example-source-readers@example.com"
          customer_id = "c12345678"
        },
        {
          id = "example-source-writers@example.com"
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
    cloud_source_repository = {
      name = "example"
      readers = [
        "group:example-source-readers@example.com"
      ]
      writers = [
        "group:example-source-writers@example.com"
      ]
    }

    # Required for scheduler.
    scheduler_region = "us-east1"

    build_viewers = ["group:example-cicd-viewers@example.com"]
    build_editors = ["group:example-cicd-editors@example.com"]

    terraform_root = "terraform"
    envs = [
      {
        name        = "shared"
        branch_name = "shared"
        triggers = {
          validate = {}
          plan = {}
          apply = {}
        }
        managed_dirs = [
          "devops", // NOTE: CICD service account can only update APIs on the devops project.
          "groups",
          "audit",
          "folders",
        ]
      },
      {
        name        = "dev"
        branch_name = "dev"
        triggers = {
          validate = {}
          plan = {}
          apply = {}
        }
        managed_dirs = [
          "dev/data",
        ]
      },
      {
        name        = "prod"
        branch_name = "main"
        triggers = {
          validate = {}
          plan = {}
          apply = {
            run_on_push = false # Do not auto run on push to prod branch
          }
        }
        managed_dirs = [
          "prod/data",
        ]
      }
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
      dataset_id = "1yr_folder_audit_logs"
      sink_name  = "example-bigquery-audit-logs-sink"
    }
    logs_storage_bucket = {
      name       = "7yr-folder-audit-logs"
      sink_name  = "example-storage-audit-logs-sink"
    }
    additional_filters = [
      # Need to escape \ and " to preserve them in the final filter strings.
      "logName=\\\"logs/forseti\\\"",
      "logName=\\\"logs/application\\\"",
    ]
  }
}

# Subfolders.
template "folders" {
  recipe_path = "{{$recipes}}/folders.hcl"
  output_path = "./folders"
  data = {
    folders = [
      {
        display_name = "dev"
      },
      {
        display_name = "prod"
      },
    ]
  }
}

# Dev data project for team 1.
template "project_data_dev" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./dev/data"
  data = {
    parent_type = "folder"
    parent_id   = "$${data.terraform_remote_state.folders.outputs.folder_ids[\"dev\"]}"
    project = {
      project_id = "example-data-dev"
      apis = [
        "compute.googleapis.com",
      ]
    }
    resources = {
      storage_buckets = [{
        name = "example-bucket-dev"
        labels = {
          env = "dev"
        }
      }]
    }
    terraform_addons = {
      states = [
        {
          prefix = "folders"
        }
      ]
    }
  }
}


# Prod data project for team 1.
template "project_data_prod" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./prod/data"
  data = {
    parent_type = "folder"
    parent_id   = "$${data.terraform_remote_state.folders.outputs.folder_ids[\"prod\"]}"
    project = {
      project_id         = "example-data-prod"
      is_shared_vpc_host = true
      apis = [
        "compute.googleapis.com",
      ]
    }
    resources = {
      storage_buckets = [{
        name = "example-bucket-prod"
        labels = {
          env = "prod"
        }
      }]
    }
    terraform_addons = {
      states = [
        {
          prefix = "folders"
        }
      ]
    }
  }
}
