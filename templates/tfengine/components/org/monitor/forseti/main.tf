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
  backend "gcs" {}
}

locals {
  forseti_vpc_name    = "forseti-vpc"
  forseti_subnet_name = "forseti-subnet"
  forseti_subnet_key  = "{{.COMPUTE_NETWORK_REGION}}/${local.forseti_subnet_name}"
}

# TODO(xingao): fix the data dependency in Forseti CloudSQL sub module
# https://github.com/forseti-security/terraform-google-forseti/blob/master/modules/cloudsql/main.tf
# and reuse the network component instead of putting putting the network here.
module "network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.1"

  project_id   = var.project_id
  network_name = local.forseti_vpc_name
  subnets = [{
    subnet_name   = local.forseti_subnet_name
    subnet_ip     = "10.10.10.0/24"
    subnet_region = "{{.COMPUTE_NETWORK_REGION}}"
  }]
}

module "router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.1"

  name    = "forseti-router"
  project = var.project_id
  region  = "{{.COMPUTE_NETWORK_REGION}}"
  network = module.network.network_name

  nats = [{
    name                               = "forseti-nat"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [{
      name                     = module.network.subnets[local.forseti_subnet_key].self_link
      source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
      secondary_ip_range_names = []
    }]
  }]
}

module "forseti" {
  source  = "terraform-google-modules/forseti/google"
  version = "~> 5.2.1"

  domain     = "{{.DOMAIN}}"
  project_id = var.project_id
  org_id     = var.org_id
  network    = module.network.network_name
  subnetwork = module.network.subnets[local.forseti_subnet_key].name
  composite_root_resources = [
    "organizations/${var.org_id}",
  ]

  server_region           = "{{.COMPUTE_INSTANCE_REGION}}"
  cloudsql_region         = "{{.CLOUD_SQL_INSTANCE_REGION}}"
  storage_bucket_location = "{{.STORAGE_BUCKET_LOCATION}}"
  bucket_cai_location     = "{{.STORAGE_BUCKET_LOCATION}}"

  cloudsql_private  = true
  client_enabled    = false
  server_private    = true
  server_boot_image = "gce-uefi-images/ubuntu-1804-lts"
  server_shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  manage_rules_enabled = false
}
