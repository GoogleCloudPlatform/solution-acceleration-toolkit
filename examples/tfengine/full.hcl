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

# {{$base := "../../templates/tfengine/recipes"}}

data = {
  org_id          = "12345678"
  billing_account = "000-000-000"
  state_bucket    = "example-terraform-state"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location = "us-east1"
  cloud_sql_region  = "us-central1"
  cloud_sql_zone    = "a"
  compute_region    = "us-central1"
  gke_region        = "us-central1"
  storage_location  = "us-central1"
}

# Foundation for the org.
template "foundation" {
  recipe_path = "{{$base}}/org/foundation.hcl"
  data = {
    parent_type = "organization" # One of `organization` or `folder`.
    parent_id   = "12345678"

    devops = {
      project_id = "example-devops"
      org_admin  = "group:example-org-admin@example.com"
      project_owners = [
        "group:example-devops-owners@example.com",
      ]

      # TODO(user): Uncomment and re-run the engine after generated bootstrap module has been deployed.
      # Run `terraform init` in the bootstrap module to backup its state to GCS.
      # bootstrap_gcs_backend = true
    }

    audit = {
      project_id   = "example-audit"
      dataset_name = "1yr_org_audit_logs"
      bucket_name  = "7yr-org-audit-logs"
      auditors     = "group:example-dev-auditors@example.com",
    }

    monitor = {
      project_id = "example-monitor"
      domain     = "example.com"
    }

    org_policies = {
      allowed_policy_member_customer_ids = [
        "example_customer_id",
      ]
    }

    cicd = {
      project_id = "example-devops"
      github = {
        owner = "GoogleCloudPlatform"
        name  = "example"
      }
      branch_regex                  = "master"
      continuous_deployment_enabled = true
      trigger_enabled               = true
      build_viewers = [
        "group:example-cicd-viewers@example.com",
      ]
      managed_services = [
        "container.googleapis.com",
        "sqladmin.googleapis.com",
      ]
    }
  }
}

# Central secrets deployment hosted in the devops project.
# NOTE: This deployment must be deployed first before any deployments in the
# live folder. Any non-auto filled secret data must be manually filled in by
# entering the secret manager page in console for the devops project.
template "secrets" {
  recipe_path = "{{$base}}/project/secrets.hcl"
  output_path = "./secrets"
  data = {
    project_id = "example-devops"
    secrets = [{
      secret_id = "manual-sql-db-password"
    }]
  }
}

# Top level prod folder.
template "folder_prod" {
  recipe_path = "{{$base}}/org/folder.hcl"
  output_path = "./live"
  data = {
    display_name = "prod"
  }
}

# Prod folder for team 1.
template "folder_team1" {
  recipe_path = "{{$base}}/folder/folder.hcl"
  output_path = "./live/prod"
  data = {
    display_name = "team1"
  }
}

# Prod central networks project for team 1.
template "project_networks" {
  recipe_path = "{{$base}}/folder/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    project = {
      project_id         = "example-prod-networks"
      is_shared_vpc_host = true
      apis = [
        "compute.googleapis.com",
        "container.googleapis.com",
        "servicenetworking.googleapis.com",
      ]
    }
    resources = {
      compute_networks = [{
        name = "example-network"
        subnets = [
          {
            name     = "example-sql-subnet"
            ip_range = "10.1.0.0/16"
          },
          {
            name     = "example-gke-subnet"
            ip_range = "10.2.0.0/16"
            secondary_ranges = [
              {
                name     = "example-pods-range"
                ip_range = "172.16.0.0/14"
              },
              {
                name     = "example-services-range"
                ip_range = "172.20.0.0/14"
              }
            ]
          },
        ]
        cloud_sql_private_service_access = {} # Enable SQL private service access.
      }]
    }
  }
}

# Prod central data project for team 1.
template "project_data" {
  recipe_path = "{{$base}}/folder/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    project = {
      project_id = "example-prod-data"
      apis = [
        "bigquery.googleapis.com",
        "compute.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
      ]
      shared_vpc_attachment = {
        host_project_id = "example-prod-networks"
        subnets = [{
          name = "example-sql-subnet"
        }]
      }
      # Add dependency on network deployment.
      terraform_addons = {
        deps = [{
          name = "networks"
          path = "../../example-prod-networks/resources"
        }]
      }
    }
    resources = {
      bigquery_datasets = [{
        dataset_id                  = "example_dataset"
        default_table_expiration_ms = 10000000000
        access = [
          {
            role          = "roles/bigquery.dataOwner"
            special_group = "projectOwners"
          },
          {
            role           = "roles/bigquery.dataViewer"
            group_by_email = "example-readers@example.com"
          },
        ]
      }]
      cloud_sql_instances = [{
        name               = "example-instance"
        type               = "mysql"
        network_project_id = "example-prod-networks"
        network            = "example-network"
        subnet             = "example-subnet"
        # TODO(user): Uncomment and re-run the engine after deploying secrets.
        # user_password = "$${data.google_secret_manager_secret_version.db_password.secret_data}" // Use $$ to escape.
      }]
      storage_buckets = [{
        name = "example-prod-bucket"
        iam_members = [{
          role   = "roles/storage.objectViewer"
          member = "group:example-readers@example.com"
        }]
      }]
      # TODO(user): Uncomment and re-run the engine after deploying secrets.
      # terraform_addons = {
      #   raw_config = <<EOF
      # data "google_secret_manager_secret_version" "db_password" {
      #   provider = google-beta

      #   secret  = "manual-sql-db-password"
      #   project = "example-data"
      # }
      # EOF
      # }
    }
  }
}

# Prod central apps project for team 1.
template "project_apps" {
  recipe_path = "{{$base}}/folder/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    project = {
      project_id = "example-prod-apps"
      apis = [
        "compute.googleapis.com",
        "container.googleapis.com",
      ]
      shared_vpc_attachment = {
        host_project_id = "example-prod-networks"
        subnets = [{
          name = "example-gke-subnet"
        }]
      }
      # Add dependency on network deployment.
      terraform_addons = {
        deps = [{
          name = "networks"
          path = "../../example-prod-networks/resources"
        }]
      }
    }
    resources = {
      # TODO(user): Uncomment and re-run the engine after the apps project has been deployed.
      # gke_clusters = [{
      #   name                   = "example-prod-gke-cluster"
      #   network_project_id     = "example-prod-networks"
      #   network                = "example-network"
      #   subnet                 = "example-gke-subnet"
      #   ip_range_pods_name     = "example-pods-range"
      #   ip_range_services_name = "example-services-range"
      #   master_ipv4_cidr_block = "192.168.0.0/28"
      # }]
      service_accounts = [{
        account_id = "example-sa"
      }]
    }
  }
}
