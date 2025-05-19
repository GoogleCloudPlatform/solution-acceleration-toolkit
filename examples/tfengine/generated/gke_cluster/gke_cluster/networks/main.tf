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
    prefix = "gke_cluster/networks"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0.0"

  name            = "example-networks"
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
  enable_shared_vpc_host_project     = true
  activate_apis                      = []
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.1.0"

  network_name = "network"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.2.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
  ]
  secondary_ranges = {
    "gke-subnet" = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.16.0.0/14"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.20.0.0/14"
      },
    ],
  }
}
