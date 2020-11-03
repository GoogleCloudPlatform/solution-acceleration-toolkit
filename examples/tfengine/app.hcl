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
        env_code          = "s"
        folder_id         = "123"
        billing_account   = "000"
        project_prefix    = "example-prefix"
        state_bucket      = "example-state"
        cloud_sql_region  = "us-central1"
        cloud_sql_zone    = "a"
        compute_region    = "us-central1"
        gke_region        = "us-central1"
        storage_location  = "us-central1"
        secret_locations  = ["us-central1"]
      }
      dev = {
        env_code  = "d"
        folder_id = "456"
      }
    }
    devops = {
      admins_group  = "admins@example.com"
      devops_owners = ["group:devops-owners-group@example.com"]
    }
    deployments = [
      {
        name = "project_secrets",
        resources = {
          project = {
            name_suffix = "secrets"
            apis = ["secretmanager.googleapis.com"]
          }
          secrets = [
            {
              secret_id = "manual-sql-db-user"
            },
            {
              secret_id   = "auto-sql-db-password"
              secret_data = "$${random_password.db.result}" // Use $$ to escape reference.
            },
          ]
        }
        terraform_addons = {
      raw_config = <<EOF
resource "random_password" "db" {
  length = 16
  special = true
}
EOF
        }
      },
      {
        name = "project_networks",
        resources = {
          project = {
            name_suffix        = "networks"
            is_shared_vpc_host = true
            apis = ["compute.googleapis.com"]
          }
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
              {
                name     = "example-instance-subnet"
                ip_range = "10.3.0.0/16"
              }
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
        }
      },
      {
        name = "project_data",
        resources = {
          project = {
            name_suffix = "data"
            shared_vpc_attachment = {
              host_project_suffix = "networks"
            }
          }
          bigquery_datasets = [{
            # Override Terraform resource name as it cannot start with a number.
            resource_name               = "one_billion_ms_example_dataset"
            dataset_id                  = "1billion_ms_example_dataset"
            default_table_expiration_ms = 1e+9
            labels = {
              type = "phi"
            }
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
            labels = {
              type = "no-phi"
            }
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
              labels = {
                type = "phi"
              }
            }]
            fhir_stores = [{
              name    = "example-fhir-store"
              version = "R4"
              labels = {
                type = "phi"
              }
              iam_members = [{
                role   = "roles/healthcare.fhirStoreViewer"
                member = "group:example-fhir-viewers@example.com",
              }]
            }]
            hl7_v2_stores = [{
              name = "example-hl7-store"
              labels = {
                type = "phi"
              }
            }]
          }]
          iam_members = {
            "roles/cloudsql.client" = [
              "serviceAccount:bastion@example-prod-networks.iam.gserviceaccount.com",
            ]
          }
          storage_buckets = [{
            name_suffix = "example-prod-bucket"
            labels = {
              type = "phi"
            }
            # TTL 7 days.
            lifecycle_rules = [{
              action = {
                type = "Delete"
              }
              condition = {
                age        = 7
                with_state = "ANY"
              }
            }]
            iam_members = [{
              role   = "roles/storage.objectViewer"
              member = "group:example-readers@example.com"
            }]
          }]
        }
        terraform_addons = {
          /* TODO(user): Uncomment and re-run the engine after deploying secrets.
          raw_config = <<EOF
    data "google_secret_manager_secret_version" "db_user" {
      provider = google-beta

      secret  = "manual-sql-db-user"
      project = "example-prod-secrets"
    }

    data "google_secret_manager_secret_version" "db_password" {
      provider = google-beta

      secret  = "auto-sql-db-password"
      project = "example-prod-secrets"
    }
    EOF
    */
        }
      },
      {
        name = "project_apps",
        resources = {
          project = {
            name_suffix        = "apps"
            shared_vpc_attachment = {
              host_project_suffix = "networks"
            }
            apis = ["compute.googleapis.com"]
          }
          gke_clusters = [{
            name                   = "example-gke-cluster"
            network_project_id     = "example-prod-networks"
            network                = "example-network"
            subnet                 = "example-gke-subnet"
            ip_range_pods_name     = "example-pods-range"
            ip_range_services_name = "example-services-range"
            master_ipv4_cidr_block = "192.168.0.0/28"
            service_account        = "gke@example-prod-apps.iam.gserviceaccount.com"
            labels = {
              type = "no-phi"
            }
          }]
          binary_authorization = {
            admission_whitelist_patterns = [{
              name_pattern = "gcr.io/cloudsql-docker/*"
            }]
          }
        }
      },
    ]
  }
}
