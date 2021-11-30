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
      id     = "example-folder-admins@example.com"
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
          id          = "example-auditors@example.com"
          customer_id = "c12345678"
          owners = [
            "user1@example.com"
          ]
        },
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
      id = "cloudbuild-sa"
    }
    logs_bucket = "example-devops-cloudbuild-logs-bucket"

    envs = [
      {
        name        = "prod"
        branch_name = "main"
        triggers = {
          validate = {}
          plan = {
            run_on_schedule = "0 12 * * *" # Run at 12 PM EST everyday
          }
          apply = {
            run_on_push = false # Do not auto run on push to branch
          }
        }
        managed_dirs = [
          "groups",
          "audit",
          "example-prod-networks",
          "folders",
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
      name      = "7yr-folder-audit-logs"
      sink_name = "example-storage-audit-logs-sink"
    }
    additional_filters = [
      # Need to escape \ and " to preserve them in the final filter strings.
      "logName=\\\"logs/application\\\"",
    ]
    terraform_addons = {
      # Example Terraform provider constraints.
      providers = [
        {
          name = "google",
          version_constraints = ">=3.0, <= 3.71"
        },
        {
          name = "google-beta",
          version_constraints = "~>3.50"
        }
      ]
    }
  }
}

# Prod central networks project for team 1.
template "project_networks" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./example-prod-networks"
  data = {
    project = {
      project_id         = "example-prod-networks"
      is_shared_vpc_host = true
      apis = [
        "compute.googleapis.com",
      ]
    }
    resources = {
      compute_networks = [{
        name = "example-network"
        subnets = [
          {
            name     = "example-subnet"
            ip_range = "10.1.0.0/16"
          },
        ]
      }]
      compute_routers = [{
        name    = "example-router"
        network = "$${module.example_network.network.network.self_link}"
        nats = [{
          name                               = "example-nat"
          source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
          subnetworks = [{
            name                     = "$${module.example_network.subnets[\"us-central1/example-subnet\"].self_link}"
            source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
            secondary_ip_range_names = []
          }]
        }]
      }]
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
        display_name = "dev"
      },
      {
        display_name  = "team1"
        resource_name = "dev_team1" // Prevent name conflict with prod/team1.
        parent        = "$${google_folder.dev.name}"
      }
    ]
  }
}
