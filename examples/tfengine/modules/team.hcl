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

data = {
  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location   = "us-east1"
  cloud_sql_region    = "{{.default_location}}"
  cloud_sql_zone      = "{{.default_zone}}"
  compute_region      = "{{.default_location}}"
  compute_zone        = "{{.default_zone}}"
  gke_region          = "{{.default_location}}"
  healthcare_location = "{{.default_location}}"
  storage_location    = "{{.default_location}}"
  secret_locations    = ["{{.default_location}}"]
}

# Central secrets project and deployment.
# NOTE: Any secret in this deployment that is not automatically filled in with
# a value must be filled manually in the GCP console secret manager page before
# any deployment can access its value.
template "project_secrets" {
  recipe_path = "{{.recipes}}/project.hcl"
  output_path = "./project_secrets"
  data = {
    project = {
      project_id = "{{.prefix}}-{{.env}}-secrets"
      apis = [
        "secretmanager.googleapis.com"
      ]
    }
    resources = {
      secrets = [
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
  }
}

# Prod central networks project for team 1.
template "project_networks" {
  recipe_path = "{{.recipes}}/project.hcl"
  output_path = "./project_networks"
  data = {
    project = {
      project_id         = "{{.prefix}}-{{.env}}-networks"
      is_shared_vpc_host = true
      apis = [
        "compute.googleapis.com",
        "container.googleapis.com",
        "iap.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
      ]
    }
    resources = {
      compute_networks = [{
        name = "network"
        subnets = [
          {
            name     = "bastion-subnet"
            ip_range = "10.1.0.0/16"
          },
          {
            name     = "gke-subnet"
            ip_range = "10.2.0.0/16"
            secondary_ranges = [
              {
                name     = "pods-range"
                ip_range = "172.16.0.0/14"
              },
              {
                name     = "services-range"
                ip_range = "172.20.0.0/14"
              }
            ]
          },
          {
            name     = "instance-subnet"
            ip_range = "10.3.0.0/16"
          }
        ]
        cloud_sql_private_service_access = {} # Enable SQL private service access.
      }]
      bastion_hosts = [{
        name           = "bastion-vm"
        network        = "$${module.network.network.network.self_link}"
        subnet         = "$${module.network.subnets[\"{{.default_location}}/bastion-subnet\"].self_link}"
        image_family   = "ubuntu-2004-lts"
        image_project  = "ubuntu-os-cloud"
        members        = ["group:{{.prefix}}-bastion-accessors@{{.domain}}"]
        startup_script = <<EOF
sudo apt-get -y update
sudo apt-get -y install mysql-client
sudo wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
sudo chmod +x /usr/local/bin/cloud_sql_proxy
EOF
      }]
      compute_routers = [{
        name    = "router"
        network = "$${module.network.network.network.self_link}"
        nats = [{
          name                               = "nat"
          source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
          subnetworks = [{
            name                     = "$${module.network.subnets[\"{{.default_location}}/bastion-subnet\"].self_link}"
            source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
            secondary_ip_range_names = []
          }]

        }]
      }]
    }
  }
}

# Prod central apps project for team 1.
template "project_apps" {
  recipe_path = "{{.recipes}}/project.hcl"
  output_path = "./project_apps"
  data = {
    project = {
      project_id = "{{.prefix}}-{{.env}}-apps"
      apis = [
        "compute.googleapis.com",
        "dns.googleapis.com",
        "container.googleapis.com",
        "pubsub.googleapis.com",
      ]
      shared_vpc_attachment = {
        host_project_id = "{{.prefix}}-{{.env}}-networks"
        subnets = [{
          name = "gke-subnet"
        }]
      }
    }
    resources = {
      gke_clusters = [{
        name                   = "gke-cluster"
        network_project_id     = "{{.prefix}}-{{.env}}-networks"
        network                = "network"
        subnet                 = "gke-subnet"
        ip_range_pods_name     = "pods-range"
        ip_range_services_name = "services-range"
        master_ipv4_cidr_block = "192.168.0.0/28"
        service_account        = "$${google_service_account.runner.account_id}@{{.prefix}}-{{.env}}-apps.iam.gserviceaccount.com"

        # Set custom node pool to control machine type.
        node_pools = [{
          name         = "default-node-pool"
          machine_type = "e2-small"
        }]
        labels = {
          type = "no-phi"
        }
      }]
      binary_authorization = {
        admission_whitelist_patterns = [{
          name_pattern = "gcr.io/cloudsql-docker/*"
        }]
      }
      service_accounts = [{
        account_id   = "runner"
        description  = "Service Account"
        display_name = "Service Account"
      }]
      compute_instance_templates = [{
        name_prefix        = "instance-template"
        network_project_id = "{{.prefix}}-{{.env}}-networks"
        subnet             = "instance-subnet"
        service_account    = "$${google_service_account.runner.email}"
        image_family       = "ubuntu-2004-lts"
        image_project      = "ubuntu-os-cloud"
        labels = {
          type = "no-phi"
        }
        tags = [
          "service",
        ]
        instances = [{
          name = "instance"
          access_configs = [{
            nat_ip       = "$${google_compute_address.static.address}"
            network_tier = "PREMIUM"
          }]
        }]
      }]
      iam_members = {
        "roles/container.viewer" = ["group:{{.prefix}}-apps-viewers@{{.domain}}"]
        "roles/storage.objectViewer" = [
          "serviceAccount:$${google_service_account.runner.account_id}@{{.prefix}}-{{.env}}-apps.iam.gserviceaccount.com",
        ]
      }
      dns_zones = [{
        name   = "domain"
        domain = "{{.domain}}."
        type   = "public"
        record_sets = [{
          name = "record"
          type = "A"
          ttl  = 30
          records = [
            "142.0.0.0",
          ]
        }]
      }]
    }
    terraform_addons = {
      raw_config = <<EOF
resource "google_compute_address" "static" {
  name = "static-ipv4-address"
}
EOF
    }
  }
}

# Prod central data project for team 1.
template "project_data" {
  recipe_path = "{{.recipes}}/project.hcl"
  output_path = "./project_data"
  data = {
    project = {
      project_id = "{{.prefix}}-{{.env}}-data"
      apis = [
        "bigquery.googleapis.com",
        "compute.googleapis.com",
        "servicenetworking.googleapis.com",
        "sqladmin.googleapis.com",
      ]
      api_identities = [
        # Need to create stream configs for Cloud Healthcare FHIR store.
        {
          api = "healthcare.googleapis.com"
          roles = [
            "roles/bigquery.dataEditor",
            "roles/bigquery.jobUser"
          ]
        },
      ]
      shared_vpc_attachment = {
        host_project_id = "{{.prefix}}-{{.env}}-networks"
      }
    }
    resources = {
      bigquery_datasets = [{
        # Override Terraform resource name as it cannot start with a number.
        resource_name               = "one_billion_ms_dataset"
        dataset_id                  = "1billion_ms_dataset"
        default_table_expiration_ms = 1e+9
        labels = {
          type = "phi"
        }
      }]
      cloud_sql_instances = [{
        name               = "sql-instance"
        type               = "mysql"
        network_project_id = "{{.prefix}}-{{.env}}-networks"
        network            = "network"
        tier               = "db-n1-standard-1"
        labels = {
          type = "no-phi"
        }
        user_name = "admin"
        # TODO(user): uncomment once secret project has been deployed
        # user_password    = "$${data.google_secret_manager_secret_version.db_password.secret_data}"
      }]
      healthcare_datasets = [{
        name = "healthcare-dataset"
        consent_stores = [{
          name = "consent-store"
          labels = {
            type = "phi"
          }
          enable_consent_create_on_update = true
          default_consent_ttl = "90000s"
        }]
        dicom_stores = [{
          name = "dicom-store"
          notification_config = {
            pubsub_topic = "projects/{{.prefix}}-{{.env}}-apps/topics/$${module.topic.topic}"
          }
          labels = {
            type = "phi"
          }
        }]
        fhir_stores = [
          {
            name                          = "fhir-store-a"
            version                       = "R4"
            enable_update_create          = true
            disable_referential_integrity = false
            disable_resource_versioning   = false
            enable_history_import         = false
            labels = {
              type = "phi"
            }
            notification_config = {
              pubsub_topic = "projects/{{.prefix}}-{{.env}}-apps/topics/$${module.topic.topic}"
            }
            stream_configs = [{
              resource_types = [
                "Patient",
              ]
              bigquery_destination = {
                dataset_uri = "bq://{{.prefix}}-{{.env}}-data.dataset_id"
                schema_config = {
                  schema_type               = "ANALYTICS"
                  recursive_structure_depth = 3
                }
              }
            }]
          },
          {
            name    = "fhir-store-b"
            version = "R4"
            labels = {
              type = "phi"
            }
          }
        ]
        hl7_v2_stores = [{
          name = "hl7-store"
          notification_configs = [{
            pubsub_topic = "projects/{{.prefix}}-{{.env}}-apps/topics/$${module.topic.topic}"
          }]
          parser_config = {
            schema  = <<EOF
{
  "schematizedParsingType": "SOFT_FAIL",
  "ignoreMinOccurs": true
}
EOF
            version = "V2"
          }
          labels = {
            type = "phi"
          }
        }]
      }]
      iam_members = {
        "roles/cloudsql.client" = [
          "serviceAccount:bastion@{{.prefix}}-{{.env}}-networks.iam.gserviceaccount.com",
        ]
      }
      storage_buckets = [{
        name = "bucket"
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
        retention_policy = {
          retention_period = 86400 # 1 day.
        }
        iam_members = [{
          role   = "roles/storage.objectViewer"
          member = "group:{{.prefix}}-data-viewers@{{.domain}}"
        }]
      }]
      pubsub_topics = [{
        name = "topic"
        labels = {
          type = "no-phi"
        }
        push_subscriptions = [
          {
            name          = "push-subscription"
            push_endpoint = "https://{{.domain}}" // required
          }
        ]
        pull_subscriptions = [
          {
            name = "pull-subscription"
          }
        ]
      }]
    }
    terraform_addons = {
      /* TODO(user): Uncomment and re-run the engine after deploying secrets.
      raw_config = <<EOF
data "google_secret_manager_secret_version" "db_password" {
  provider = google-beta

  secret  = "auto-sql-db-password"
  project = "{{.prefix}}-{{.env}}-secrets"
}
EOF
*/
    }
  }
}

# Kubernetes Terraform deployment. This should be deployed after the GKE Cluster has been deployed.
template "kubernetes" {
  recipe_path = "{{.recipes}}/deployment.hcl"
  output_path = "./kubernetes"

  data = {
    terraform_addons = {
      raw_config = <<EOF
data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = "{{.default_location}}"
  project  = "{{.prefix}}-{{.env}}-apps"
}

provider "kubernetes" {
  load_config_file       = false
  token                  = data.google_client_config.default.access_token
  host                   = data.google_container_cluster.gke_cluster.endpoint
  client_certificate     = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "namespace"
    annotations = {
      name = "namespace"
    }
  }
}
EOF
    }
  }
}
