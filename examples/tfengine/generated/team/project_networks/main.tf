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
    prefix = "project_networks"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0.0"

  name            = "example-prod-networks"
  org_id          = ""
  folder_id       = "12345678"
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
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "dns.googleapis.com",
  ]
  labels = {
    env = "prod"
  }
}

module "bastion_vm" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 8.0.0"

  name         = "bastion-vm"
  project      = module.project.project_id
  zone         = "us-central1-a"
  host_project = module.project.project_id
  network      = module.network.network.network.self_link
  subnet       = module.network.subnets["us-central1/bastion-subnet"].self_link
  members      = ["serviceAccount:${google_service_account.bastion_accessor.email}"]
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

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.1.0"

  network_name = "network"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "bastion-subnet"
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.2.0.0/16"
      subnet_region         = "us-central1"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
    {
      subnet_name           = "instance-subnet"
      subnet_ip             = "10.3.0.0/16"
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
module "cloud_sql_private_service_access_network" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version = "~> 25.2.0"

  project_id  = module.project.project_id
  vpc_network = module.network.network_name
  depends_on = [
    module.project
  ]
}

module "router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 7.0.0"

  name    = "router"
  project = module.project.project_id
  region  = "us-central1"
  network = module.network.network.network.self_link

  nats = [
    {
      name                               = "nat"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

      subnetworks = [
        {
          name                     = "${module.network.subnets["us-central1/bastion-subnet"].self_link}"
          source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
          secondary_ip_range_names = []
        },
      ]
    },
  ]
}

module "google_apis" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 6.0.0"

  name       = "google-apis"
  project_id = module.project.project_id
  domain     = "googleapis.com."
  type       = "private"

  private_visibility_config_networks = ["${module.network.network.network.self_link}"]
  recordsets = [
    {
      name = "private"

      records = [
        "199.36.153.8",
        "199.36.153.9",
        "199.36.153.10",
        "199.36.153.11",
      ]

      ttl  = 300
      type = "A"
    },
    {
      name    = "*"
      records = ["private.googleapis.com."]
      ttl     = 300
      type    = "CNAME"
    },
  ]
}

module "gcr" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 6.0.0"

  name       = "gcr"
  project_id = module.project.project_id
  domain     = "gcr.io."
  type       = "private"

  private_visibility_config_networks = ["${module.network.network.network.self_link}"]
  recordsets = [
    {
      name = ""

      records = [
        "199.36.153.8",
        "199.36.153.9",
        "199.36.153.10",
        "199.36.153.11",
      ]

      ttl  = 300
      type = "A"
    },
    {
      name    = "*"
      records = ["gcr.io."]
      ttl     = 300
      type    = "CNAME"
    },
  ]
}

resource "google_service_account" "bastion_accessor" {
  account_id   = "bastion-accessor"
  display_name = "Bastion Accessor Service Account"

  description = "Placeholder service account to use as members who can access the bastion host."

  project = module.project.project_id
}
