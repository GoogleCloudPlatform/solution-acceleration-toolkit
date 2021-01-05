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
  required_version = ">=0.13"
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
  version = "~> 10.0.1"

  name                           = "example-prod-networks"
  org_id                         = ""
  folder_id                      = "12345678"
  billing_account                = "000-000-000"
  lien                           = true
  default_service_account        = "keep"
  enable_shared_vpc_host_project = true
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}

module "bastion_vm" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 2.10.0"

  name         = "bastion-vm"
  project      = module.project.project_id
  zone         = "us-central1-a"
  host_project = module.project.project_id
  network      = module.example_network.network.network.self_link
  subnet       = module.example_network.subnets["us-central1/example-bastion-subnet"].self_link
  members      = ["group:bastion-accessors@example.com"]
  image_family = "ubuntu-2004-lts"

  image_project = "ubuntu-os-cloud"



  labels = {
    env = "prod"
  }

  startup_script = <<EOF
sudo apt-get -y update
sudo apt-get -y install mysql-client
sudo wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
sudo chmod +x /usr/local/bin/cloud_sql_proxy

EOF
}

module "example_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.6.0"

  network_name = "example-network"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "example-bastion-subnet"
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
    {
      subnet_name           = "example-gke-subnet"
      subnet_ip             = "10.2.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
    {
      subnet_name           = "example-instance-subnet"
      subnet_ip             = "10.3.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
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
  version = "~> 4.4.0"

  project_id  = module.project.project_id
  vpc_network = module.example_network.network_name
  depends_on = [
    module.project
  ]
}

module "example_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4.0"

  name    = "example-router"
  project = module.project.project_id
  region  = "us-central1"
  network = module.example_network.network.network.self_link

  nats = [
    {
      name                               = "example-nat"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

      subnetworks = [
        {
          name                     = "${module.example_network.subnets["us-central1/example-bastion-subnet"].self_link}"
          source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
          secondary_ip_range_names = []
        },
      ]
    },
  ]
}
