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
    prefix = "additional_iam_members"
  }
}

module "storage_bucket_iam_members" {
  source          = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  mode            = "additive"
  for_each        = var.storage_bucket_iam_members
  storage_buckets = each.value.parent_ids
  bindings        = each.value.bindings
}

module "project_iam_members" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  mode     = "additive"
  for_each = var.project_iam_members
  projects = each.value.parent_ids
  bindings = each.value.bindings
}


module "folder_iam_members" {
  source   = "terraform-google-modules/iam/google//modules/folders_iam"
  mode     = "additive"
  for_each = var.folder_iam_members
  folders  = each.value.parent_ids
  bindings = each.value.bindings
}

module "organization_iam_members" {
  source        = "terraform-google-modules/iam/google//modules/organizations_iam"
  mode          = "additive"
  for_each      = var.organization_iam_members
  organizations = each.value.parent_ids
  bindings      = each.value.bindings
}

module "service_account_iam_members" {
  source           = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  mode             = "additive"
  for_each         = var.service_account_iam_members
  service_accounts = each.value.parent_ids
  bindings         = each.value.bindings
}
