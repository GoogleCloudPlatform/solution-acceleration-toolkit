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

terraform {
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "example-prod-networks"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 9.2.0"

  name                           = "example-prod-networks"
  org_id                         = "12345678"
  billing_account                = "000-000-000"
  lien                           = true
  default_service_account        = "keep"
  skip_gcloud_download           = true
  enable_shared_vpc_host_project = true
  activate_apis                  = ["compute.googleapis.com"]
}

module "example_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5.0"

  network_name = "example-network"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "forseti-subnet"
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
  ]
}

module "forseti_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.3.0"

  name    = "forseti-router"
  project = module.project.project_id
  region  = "us-central1"
  network = module.example_network.network.network.self_link

  nats = [
    {
      name                               = "forseti-nat"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

      subnetworks = [
        {
          name                     = "${module.example_network.subnets["us-central1/forseti-subnet"].self_link}"
          source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
          secondary_ip_range_names = []
        },
      ]
    },
  ]
}
