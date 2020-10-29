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

module "constants" {
  source = "../../../constants"
}

locals {
  constants = merge(module.constants.values.shared, module.constants.values[var.env])
}
# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 9.2.0"

  name                    = "${local.constants.project_prefix}-${local.constants.env_code}-networks"
  org_id                  = ""
  folder_id               = local.constants.folder_id
  billing_account         = local.constants.billing_account
  lien                    = true
  default_service_account = "keep"
  skip_gcloud_download    = true
  activate_apis           = ["compute.googleapis.com"]
}

module "example_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.5.0"

  network_name = "example-network"
  project_id   = module.project.project_id

  subnets = [
    {
      subnet_name           = "example-gke-subnet"
      subnet_ip             = "10.1.0.0/16"
      subnet_region         = "<no value>"
      subnet_flow_logs      = true
      subnet_private_access = true
    },
  ]
}
