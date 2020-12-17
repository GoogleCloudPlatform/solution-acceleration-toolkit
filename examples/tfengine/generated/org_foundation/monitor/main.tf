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
    prefix = "monitor"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 10.0.1"

  name                    = "example-monitor"
  org_id                  = "12345678"
  billing_account         = "000-000-000"
  lien                    = true
  default_service_account = "keep"

  shared_vpc    = "example-prod-networks"
  activate_apis = []
}


module "forseti" {
  source  = "terraform-google-modules/forseti/google"
  version = "~> 5.2.1"

  domain          = "example.com"
  project_id      = module.project.project_id
  org_id          = "12345678"
  network_project = "example-prod-networks"
  network         = "example-network"
  subnetwork      = "forseti-subnet"
  composite_root_resources = [
    "organizations/12345678",
  ]

  server_region           = "us-central1"
  cloudsql_region         = "us-central1"
  storage_bucket_location = "us-central1"
  bucket_cai_location     = "us-central1"

  cloudsql_private  = true
  client_enabled    = false
  server_private    = true
  server_boot_image = "gce-uefi-images/ubuntu-1804-lts"
  server_shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  manage_rules_enabled     = false
  config_validator_enabled = true
}
