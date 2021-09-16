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
  parent_type      = "organization" # One of `organization` or `folder`.
  parent_id        = "12345678"
  billing_account  = "000-000-000"
  state_bucket     = "example-terraform-state"
  storage_location = "us-central1"
  compute_region   = "us-central1"
}

template "networks" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./gke_cluster/networks"
  data = {
    project = {
      project_id         = "networks-example-project"
      is_shared_vpc_host = true
    }
    resources = {
      compute_networks = [{
        name = "network"
        subnets = [
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
      }]
    }
  }
}

template "cluster" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./gke_cluster/cluster"
  data = {
    project = {
      project_id = "cluster-project-example"
      shared_vpc_attachment = {
        host_project_id = "networks-example-project"
        subnets = [{
          name = "gke-subnet"
        }]
      }
    }
    resources = {
      gke_clusters = [{
        name                   = "gke-cluster"
        network_project_id     = "networks-example-project"
        network                = "network"
        subnet                 = "gke-subnet"
        ip_range_pods_name     = "pods-range"
        ip_range_services_name = "services-range"
        master_ipv4_cidr_block = "192.168.0.0/28"
      }]
      service_accounts = [{
        account_id   = "example-sa"
        description  = "Service Account"
        display_name = "Service Account"
      }]
      compute_instance_templates = [{
        name_prefix        = "instance-template"
        network_project_id = "networks-example-project"
        subnet             = "instance-subnet"
        service_account    = "$${google_service_account.example_sa.email}"
        image_family       = "ubuntu-2004-lts"
        image_project      = "ubuntu-os-cloud"

        instances = [{
          name = "instance"
          access_configs = [{
            nat_ip       = "$${google_compute_address.static.address}"
            network_tier = "PREMIUM"
          }]
        }]
      }]
    }
    terraform_addons = {
      raw_config = <<EOF
resource "google_compute_address" "static" {
  name    = "static-ipv4-address"
  project = module.project.project_id
  region  = "us-central1"
}
EOF
    }
  }
}

template "kubernetes" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./gke_cluster/kubernetes"

  data = {
    project = {
      project_id = "cluster-project-example"
      exists     = true
    }
    resources = {
      kubernetes_service_accounts = [{
        name = "ksa-gke"
        namespace = "example-namespace"
        google_service_account_email = "example-sa@cluster-project-example.iam.gserviceaccount.com"
        provider = "gke-alias"
      }]
      workload_identity_configurations = [{
        project_id = "cluster-project-example"
        google_service_account_id = "example-sa"
        kubernetes_service_account_name = "ksa-gke"
        namespace = "example-namespace"
        cluster_name = "gke-cluster"
        location = "us-central1"
      }]
    }
    terraform_addons = {
      raw_config = <<EOF
data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = "us-central1"
  project  = "cluster-project-example"
}

provider "kubernetes" {
  alias                  = "gke-alias"
  load_config_file       = false
  token                  = data.google_client_config.default.access_token
  host                   = data.google_container_cluster.gke_cluster.endpoint
  client_certificate     = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "namespace" {
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