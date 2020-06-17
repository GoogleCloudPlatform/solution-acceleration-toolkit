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
  parent_type     = "organization" # One of `organization` or `folder`.
  parent_id       = "12345678"
  org_id          = "12345678" # TODO(umairidris): deprecate this field.
  billing_account = "000-000-000"
  state_bucket    = "example-terraform-state"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location   = "us-east1"
  cloud_sql_region    = "us-central1"
  cloud_sql_zone      = "a"
  compute_region      = "us-central1"
  compute_zone        = "a"
  gke_region          = "us-central1"
  healthcare_location = "us-central1"
  storage_location    = "us-central1"
}

template "devops" {
  recipe_path = "{{$recipes}}/devops.hcl"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated bootstrap module has been deployed.
    # Run `terraform init` in the bootstrap module to backup its state to GCS.
    # bootstrap_gcs_backend = true

    project_id   = "example-devops"
    state_bucket = "example-terraform-state"
    org_admin    = "group:example-org-admin@example.com"
    project_owners = [
      "group:example-devops-owners@example.com",
    ]

    cicd = {
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
        "firebase.googleapis.com",
        "healthcare.googleapis.com",
        "iap.googleapis.com",
        "secretmanager.googleapis.com",
      ]
    }
  }
}

template "audit" {
  recipe_path = "{{$recipes}}/audit.hcl"
  output_path = "./live"
  data = {
    project_id   = "example-audit"
    dataset_name = "1yr_org_audit_logs"
    bucket_name  = "7yr-org-audit-logs"
    auditors     = "group:example-dev-auditors@example.com"
  }
}

template "monitor" {
  recipe_path = "{{$recipes}}/monitor.hcl"
  output_path = "./live"
  data = {
    project_id     = "example-monitor"
    domain         = "example.com"
    cscc_source_id = "organizations/12345678/sources/88888888"
  }
}

template "org_policies" {
  recipe_path = "{{$recipes}}/org_policies.hcl"
  output_path = "./live"
  data = {
    allowed_policy_member_customer_ids = [
      "example_customer_id",
    ]
  }
}

# Central secrets project and deployment.
# NOTE: This deployment must be deployed first before any deployments in the
# live folder. Any non-auto filled secret data must be manually filled in by
# entering the secret manager page in console.
template "project_secrets" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./live/secrets"
  data = {
    project = {
      project_id = "example-secrets"
      apis = [
        "secretmanager.googleapis.com"
      ]
    }
    deployments = {
      resources = {
        secrets = [
          {
            secret_id = "manual-sql-db-user"
          },
          {
            secret_id   = "auto-sql-db-password"
            secret_data = "$${random_password.db.result}" // Use $$ to escape reference.
          },
        ]
        terraform_addons = {
          raw_config = <<EOF
resource "random_password" "db" {
  length = 16
  special = true
}
EOF
        }
      }
    }
  }
}

# Top level prod folder.
template "folder_prod" {
  recipe_path = "{{$recipes}}/folder.hcl"
  output_path = "./live"
  data = {
    display_name = "prod"
  }
}

# Prod folder for team 1.
template "folder_team1" {
  recipe_path = "{{$recipes}}/folder.hcl"
  output_path = "./live/prod"
  data = {
    parent_type  = "folder"
    display_name = "team1"
  }
}

# Prod central networks project for team 1.
template "project_networks" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    parent_type = "folder"
    project = {
      project_id         = "example-prod-networks"
      is_shared_vpc_host = true
      apis = [
        "compute.googleapis.com",
        "container.googleapis.com",
        "iap.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
      ]
    }
    deployments = {
      resources = {
        compute_networks = [{
          name = "example-network"
          subnets = [
            {
              name     = "example-bastion-subnet"
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
        bastion_hosts = [{
          name           = "bastion-vm"
          network        = "$${module.example_network.network.network.self_link}"
          subnet         = "$${module.example_network.subnets[\"us-central1/example-bastion-subnet\"].self_link}"
          image_family   = "ubuntu-2004-lts"
          image_project  = "ubuntu-os-cloud"
          members        = ["group:bastion-accessors@example.com"]
          startup_script = <<EOF
sudo apt-get -y update
sudo apt-get -y install mysql-client
sudo wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
sudo chmod +x /usr/local/bin/cloud_sql_proxy
EOF
        }]
        compute_routers = [{
          name    = "example-router"
          network = "$${module.example_network.network.network.self_link}"
          nats = [{
            name                               = "example-nat"
            source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
            subnetworks = [{
              name                     = "$${module.example_network.subnets[\"us-central1/example-bastion-subnet\"].self_link}"
              source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
              secondary_ip_range_names = []
            }]

          }]
        }]
        terraform_addons = {
          outputs = [{
            name  = "bastion_service_account"
            value = "$${module.bastion_vm.service_account}"
          }]
        }
      }
    }
  }
}

# Prod central data project for team 1.
template "project_data" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    parent_type = "folder"
    project = {
      project_id = "example-prod-data"
      apis = [
        "bigquery.googleapis.com",
        "compute.googleapis.com",
        "healthcare.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
      ]
      shared_vpc_attachment = {
        host_project_id = "example-prod-networks"
      }
      # Add dependency on network deployment.
      terraform_addons = {
        deps = [{
          name = "networks"
          path = "../../example-prod-networks/resources"
        }]
      }
    }
    deployments = {
      resources = {
        bigquery_datasets = [{
          # Override Terraform resource name as it cannot start with a number.
          resource_name               = "one_billion_ms_example_dataset"
          dataset_id                  = "1billion_ms_example_dataset"
          default_table_expiration_ms = 1e+9
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
          name               = "example-mysql-instance"
          type               = "mysql"
          network_project_id = "example-prod-networks"
          network            = "example-network"
          subnet             = "example-subnet"
          # TODO(user): Uncomment and re-run the engine after deploying secrets.
          # user_name        = "$${data.google_secret_manager_version.db_user.secret_data}"
          # user_password    = "$${data.google_secret_manager_secret_version.db_password.secret_data}"
        }]
        healthcare_datasets = [{
          name = "example-healthcare-dataset"
          iam_members = [{
            role   = "roles/healthcare.datasetViewer"
            member = "group:example-healthcare-dataset-viewers@example.com",
          }]
          dicom_stores = [{
            name = "example-dicom-store"
          }]
          fhir_stores = [{
            name    = "example-fhir-store"
            version = "R4"
            iam_members = [{
              role   = "roles/healthcare.fhirStoreViewer"
              member = "group:example-fhir-viewers@example.com",
            }]
          }]
          hl7_v2_stores = [{
            name = "example-hl7-store"
          }]
        }]
        iam_members = {
          "roles/cloudsql.client" = [
            "serviceAccount:$${var.bastion_service_account}",
          ]
        }
        storage_buckets = [{
          name = "example-prod-bucket"
          iam_members = [{
            role   = "roles/storage.objectViewer"
            member = "group:example-readers@example.com"
          }]
        }]
        terraform_addons = {
          deps = [{
            name = "networks"
            path = "../../example-prod-networks/resources"
            mock_outputs = {
              bastion_service_account = "mock-sa"
            }
          }]
          vars = [{
            name             = "bastion_service_account"
            type             = "string"
            terragrunt_input = "$${dependency.networks.outputs.bastion_service_account}"
          }]
          /* TODO(user): Uncomment and re-run the engine after deploying secrets.
          raw_config = <<EOF
data "google_secret_manager_secret_version" "db_user" {
  provider = google-beta

  secret  = "manual-sql-db-user"
  project = "example-secrets"
}

data "google_secret_manager_secret_version" "db_password" {
  provider = google-beta

  secret  = "auto-sql-db-password"
  project = "example-secrets"
}
EOF
*/
        }
      }
    }
  }
}

# Prod central apps project for team 1.
template "project_apps" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    parent_type = "folder"
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
    deployments = {
      resources = {
        # TODO(user): Uncomment and re-run the engine after the apps project has been deployed.
        # gke_clusters = [{
        #   name                   = "example-gke-cluster"
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
        iam_members = {
          "roles/container.viewer" = ["group:example-viewers@example.com"]
        }
      }
    }
  }
}

# Prod firebase project for team 1.
template "project_firebase" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./live/prod/team1"
  data = {
    parent_type = "folder"
    project = {
      project_id = "example-prod-firebase"
      apis = [
        "firebase.googleapis.com",
      ]
    }
    deployments = {
      resources = {
        terraform_addons = {
          raw_config = <<EOF
resource "google_firebase_project" "firebase" {
  provider = google-beta
  project  = var.project_id
}

resource "google_firestore_index" "index" {
  project    = var.project_id
  collection = "example-collection"
  fields {
    field_path = "__name__"
    order      = "ASCENDING"
  }
  fields {
    field_path = "example-field"
    order      = "ASCENDING"
  }
  fields {
    field_path = "createdTimestamp"
    order      = "ASCENDING"
  }
}
EOF
        }
      }
    }
  }
}

# Kubernetes Terraform deployment. This should be deployed manually as Cloud
# Build cannot access the GKE cluster and should be deployed after the GKE
# Cluster has been deployed.
template "kubernetes" {
  recipe_path = "{{$recipes}}/terraform_deployment.hcl"
  output_path = "./kubernetes"

  data = {
    state_path_prefix = "kubernetes"
    terraform_addons = {
      raw_config = <<EOF
data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = "example-gke-cluster"
  location = "us-central1"
  project  = "example-prod-apps"
}

provider "kubernetes" {
  load_config_file       = false
  token                  = data.google_client_config.default.access_token
  host                   = data.google_container_cluster.gke_cluster.endpoint
  client_certificate     = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "example_namespace" {
  metadata {
    name = "example-namespace"
    annotations = {
      name = "example-namespace"
    }
  }
}
EOF
    }
  }
}
