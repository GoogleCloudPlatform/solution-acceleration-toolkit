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
# - Admin permission at folder level,
# - Cloud Identity groups and memberships, if requested.

// TODO: replace with https://github.com/terraform-google-modules/terraform-google-bootstrap
terraform {
  required_version = ">=0.13"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
}

# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = "example-devops"
}

# Create the project, enable APIs, and create the deletion lien, if specified.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0.1"

  name                    = "example-devops"
  org_id                  = ""
  folder_id               = "12345678"
  billing_account         = "000-000-000"
  lien                    = true
  default_service_account = "keep"
  activate_apis = [
    "cloudbuild.googleapis.com",
    "cloudidentity.googleapis.com",
  ]
}

# Terraform state bucket, hosted in the devops project.
module "state_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "example-terraform-state"
  project_id = module.project.project_id
  location   = "us-central1"
}

# Devops project owners group.
module "owners_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id          = "example-devops-owners@example.com"
  customer_id = "c12345678"
  owners      = ["user1@example.com"]
  depends_on = [
    module.project
  ]
}

# Project level IAM permissions for devops project owners.
resource "google_project_iam_binding" "devops_owners" {
  project = module.project.project_id
  role    = "roles/owner"
  members = ["group:${module.owners_group.id}"]
}

# Admin permission at folder level.
resource "google_folder_iam_member" "admin" {
  folder = "folders/12345678"
  role   = "roles/resourcemanager.folderAdmin"
  member = "group:example-folder-admins@example.com"
}
