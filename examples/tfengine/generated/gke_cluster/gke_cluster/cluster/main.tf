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

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = ">= 3.0"
    google-beta = ">= 3.0"
    kubernetes  = "~> 2.10"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "gke_cluster/cluster"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0.0"

  name            = "example-apps"
  org_id          = "12345678"
  billing_account = "000-000-000"
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  svpc_host_project_id = "example-networks"
  shared_vpc_subnets = [
    "projects/example-networks/regions/us-central1/subnetworks/gke-subnet",
  ]
  activate_apis = []
}
data "google_client_config" "default" {}


provider "kubernetes" {
  alias                  = "example_cluster"
  host                   = "https://${module.example_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.example_cluster.ca_certificate)
}

module "example_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "~> 36.3.0"

  providers = {
    kubernetes = kubernetes.example_cluster
  }

  # Required.
  name               = "example-cluster"
  project_id         = module.project.project_id
  region             = "<no value>"
  regional           = true
  network_project_id = "example-networks"

  network                 = "network"
  subnetwork              = "gke-subnet"
  ip_range_pods           = "pods-range"
  ip_range_services       = "services-range"
  master_ipv4_cidr_block  = "192.168.0.0/28"
  enable_private_endpoint = false
  release_channel         = "STABLE"


  depends_on = [
    module.project
  ]
}

resource "google_service_account" "example_sa" {
  account_id   = "example-sa"
  display_name = "Service Account"

  description = "Service Account"

  project = module.project.project_id
}
