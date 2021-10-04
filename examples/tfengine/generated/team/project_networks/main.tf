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
    google      = "~> 3.0"
    google-beta = "~> 3.0"
    kubernetes  = "~> 1.0"
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
  version = "~> 11.1.0"

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
    "cloudbuild.googleapis.com",
  ]
}

module "bastion_vm" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 3.2.0"

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
  version = "~> 3.3.0"

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
  version = "~> 4.5.0"

  project_id  = module.project.project_id
  vpc_network = module.network.network_name
  depends_on = [
    module.project
  ]
}

module "router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.1.0"

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

resource "google_service_account" "bastion_accessor" {
  account_id   = "bastion-accessor"
  display_name = "Bastion Accessor Service Account"

  description = "Placeholder service account to use as members who can access the bastion host."

  project = module.project.project_id
}
resource "google_project_service" "servicenetworking" {
  service            = "servicenetworking.googleapis.com"
  project            = module.project.project_id
  disable_on_destroy = false
}

module "worker_pool_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.3.0"

  network_name = "worker-pool-network"
  project_id   = module.project.project_id

  subnets = []
}

resource "google_compute_global_address" "worker_pool_address" {
  provider      = google-beta
  name          = "worker-pool-address"
  purpose       = "VPC_PEERING"
  network       = module.worker_pool_network.network_self_link
  address_type  = "INTERNAL"
  address       = "192.168.0.0"
  prefix_length = 16
  project       = module.project.project_id
}

resource "google_service_networking_connection" "worker_pool_connection" {
  network                 = module.worker_pool_network.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.worker_pool_address.name]
  depends_on              = [google_project_service.servicenetworking]
}

resource "google_compute_network_peering_routes_config" "worker_pool_peering" {
  network              = module.worker_pool_network.network_name
  peering              = "servicenetworking-googleapis-com"
  import_custom_routes = false
  export_custom_routes = true
  project              = module.project.project_id
  depends_on = [
    google_service_networking_connection.worker_pool_connection,
    module.worker_pool_network,
  ]
}

module "private_pool_gcloud" {
  source                 = "terraform-google-modules/gcloud/google"
  version                = "~> 3.0.1"
  additional_components  = []
  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "builds worker-pools create private-pool --region=us-central1 --peered-network=projects/$${module.project.project_id}/global/networks/$${module.worker_pool_network.network_name} --project=$${module.project.project_id} --quiet"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "builds worker-pools delete private-pool --region=us-central1  --project=$${module.project.project_id} --quiet"
  module_depends_on = [
    google_compute_network_peering_routes_config.worker_pool_peering,
  ]
}
module "worker_pool_vpn_ha_1" {
  source           = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version          = "~> 1.5.0"
  project_id       = module.project.project_id
  region           = "us-central1"
  network          = module.worker_pool_network.network_self_link
  name             = "worker-pool-net-to-gke-cluster-net"
  peer_gcp_gateway = module.worker_pool_vpn_ha_2.self_link
  router_asn       = 64514
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.1"
        asn     = 64513
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "192.168.0.0/16" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.1.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = null
      shared_secret                   = ""
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.1"
        asn     = 64513
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "192.168.0.0/16" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.2.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = null
      shared_secret                   = ""
    }
  }
}

module "worker_pool_vpn_ha_2" {
  source           = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version          = "~> 1.5.0"
  project_id       = module.project.project_id
  region           = "us-central1"
  network          = module.network.network.network.self_link
  name             = "gke-cluster-net-to-worker-pool-net"
  router_asn       = 64513
  peer_gcp_gateway = module.worker_pool_vpn_ha_1.self_link
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = 64514
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "172.16.0.0/28" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.1.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = null
      shared_secret                   = module.worker_pool_vpn_ha_1.random_secret
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = 64514
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "172.16.0.0/28" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.2.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = null
      shared_secret                   = module.worker_pool_vpn_ha_1.random_secret
    }
  }
}
