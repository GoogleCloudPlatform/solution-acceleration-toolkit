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
  }
}




module "example_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3.0"

  network_name = "example-network"
  project_id   = var.project_id
  subnets = [
    {
      subnet_name            = "example-sql-subnet"
      subnet_ip              = "10.1.0.0/16"
      subnet_region          = "us-central1"
      subnet_flow_logs       = true
      subnets_private_access = true
    },
    {
      subnet_name            = "example-gke-subnet"
      subnet_ip              = "10.2.0.0/16"
      subnet_region          = "us-central1"
      subnet_flow_logs       = true
      subnets_private_access = true
    },
    
  ]
  secondary_ranges = {
    "example-gke-subnet" = [
      {
        range_name    = "example-pods-range"
        ip_cidr_range = "172.16.0.0/14"
      },
      {
        range_name    = "example-services-range"
        ip_cidr_range = "172.20.0.0/14"
      },
    ],
  }
}
module "cloud_sql_private_service_access_example_network" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version = "~> 3.2.0"

  project_id  = var.project_id
  vpc_network = module.example_network.network_name
}
