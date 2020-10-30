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

# This folder contains Terraform resources to setup the devops project, which includes:
# - The project itself,
# - APIs to enable,
# - Deletion lien,
# - Project level IAM permissions for the project owners,
# - A Cloud Storage bucket to store Terraform states for all deployments,
# - Folder level IAM permissions for admins.

terraform {
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
}

module "constants" {
  source = "../constants"
}

locals {
  constants = module.constants.values.shared
}

# Create the project, enable APIs, and create the deletion lien, if specified.
module "project" {
  source                  = "terraform-google-modules/project-factory/google"
  version                 = "~> 9.1.0"
  name                    = "${local.constants.project_prefix}-${local.constants.env_code}-devops"
  org_id                  = ""
  folder_id               = local.constants.folder_id
  billing_account         = local.constants.billing_account
  lien                    = true
  default_service_account = "keep"
  skip_gcloud_download    = true
  activate_apis = [
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sourcerepo.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}

# Terraform state bucket, hosted in the devops project.
module "state_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = local.constants.state_bucket
  project_id = module.project.project_id
  location   = local.constants.region
}

# Project level IAM permissions for devops project owners.
resource "google_project_iam_binding" "devops_owners" {
  project = module.project.project_id
  role    = "roles/owner"
  members = var.devops_owners
}

resource "google_folder_iam_member" "admin" {
  folder = "folders/${local.constants.folder_id}"
  role   = "roles/resourcemanager.folderAdmin"
  member = "group:${var.admins_group}"
}
