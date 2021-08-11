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

# This folder contains Terraform resources to setup the devops project, which includes:
# - The project itself,
# - APIs to enable,
# - Deletion lien,
# - Project level IAM permissions for the project owners,
# - A Cloud Storage bucket to store Terraform states for all deployments,
# - Admin permission at organization level,
# - Cloud Identity groups and memberships, if requested.

// TODO: replace with https://github.com/terraform-google-modules/terraform-google-bootstrap
terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
}

# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = var.project.project_id
}

# Create the project, enable APIs, and create the deletion lien, if specified.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.1.0"

  name            = var.project.project_id
  org_id          = var.parent_type == "organization" ? var.parent_id : ""
  folder_id       = var.parent_type == "folder" ? var.parent_id : ""
  billing_account = var.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  activate_apis     = var.project.apis
}

# Terraform state bucket, hosted in the devops project.
module "state_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = var.state_bucket
  project_id = module.project.project_id
  location   = var.storage_location
}

# Devops project owners group.
module "owners_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.2"

  count = var.project.owners_group.exists ? 0 : 1

  id           = var.project.owners_group.id
  customer_id  = var.project.owners_group.customer_id
  display_name = var.project.owners_group.display_name
  description  = var.project.owners_group.description
  owners       = var.project.owners_group.owners
  managers     = var.project.owners_group.managers
  members      = var.project.owners_group.members
  depends_on = [
    module.project
  ]
}

# The group is not ready for IAM bindings right after creation. Wait for
# a while before it is used.
resource "time_sleep" "owners_wait" {
  count = var.project.owners_group.exists ? 0 : 1
  depends_on = [
    module.owners_group[0],
  ]
  create_duration = "15s"
}

# Project level IAM permissions for devops project owners.
resource "google_project_iam_binding" "devops_owners" {
  project    = module.project.project_id
  role       = "roles/owner"
  members    = ["group:${var.project.owners_group.exists ? var.project.owners_group.id : module.owners_group[0].id}"]
  depends_on = [time_sleep.owners_wait]
}

# Admins group at parent level.
module "admins_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.2"

  count = var.admins_group.exists ? 0 : 1

  id           = var.admins_group.id
  customer_id  = var.admins_group.customer_id
  display_name = var.admins_group.display_name
  description  = var.admins_group.description
  owners       = var.admins_group.owners
  managers     = var.admins_group.managers
  members      = var.admins_group.members
  depends_on = [
    module.project
  ]
}

# The group is not ready for IAM bindings right after creation. Wait for
# a while before it is used.
resource "time_sleep" "admins_wait" {
  count = var.admins_group.exists ? 0 : 1
  depends_on = [
    module.admins_group[0],
  ]
  create_duration = "15s"
}

resource "google_organization_iam_member" "admin" {
  count      = var.parent_type == "organization" ? 1 : 0
  org_id     = var.parent_id
  role       = "roles/resourcemanager.organizationAdmin"
  member     = "group:${var.admins_group.exists ? var.admins_group.id : module.admins_group[0].id}"
  depends_on = [time_sleep.admins_wait]
}

resource "google_folder_iam_member" "admin" {
  count      = var.parent_type == "folder" ? 1 : 0
  folder     = "folders/${var.parent_id}"
  role       = "roles/resourcemanager.folderAdmin"
  member     = "group:${var.admins_group.exists ? var.admins_group.id : module.admins_group[0].id}"
  depends_on = [time_sleep.admins_wait]
}
