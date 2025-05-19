{{- /* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

module "storage_bucket_iam_members" {
  source = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "~> 8.1.0"
  mode   = "additive"
  for_each = {
    for idx, member in var.storage_bucket_iam_members :
    idx => member
  }
  storage_buckets = each.value.resource_ids
  bindings        = each.value.bindings
}

module "project_iam_members" {
  source = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 8.1.0"
  mode   = "additive"
  for_each = {
    for idx, member in var.project_iam_members :
    idx => member
  }
  projects = each.value.resource_ids
  bindings = each.value.bindings
}

module "folder_iam_members" {
  source = "terraform-google-modules/iam/google//modules/folders_iam"
  version = "~> 8.1.0"
  mode   = "additive"
  for_each = {
    for idx, member in var.folder_iam_members :
    idx => member
  }
  folders  = each.value.resource_ids
  bindings = each.value.bindings
}

module "organization_iam_members" {
  source = "terraform-google-modules/iam/google//modules/organizations_iam"
  version = "~> 8.1.0"
  mode   = "additive"
  for_each = {
    for idx, member in var.organization_iam_members :
    idx => member
  }
  organizations = each.value.resource_ids
  bindings      = each.value.bindings
}

module "service_account_iam_members" {
  source = "terraform-google-modules/iam/google//modules/service_accounts_iam"
  version = "~> 8.1.0"
  mode   = "additive"
  for_each = {
    for idx, member in var.service_account_iam_members :
    idx => member
  }
  service_accounts = each.value.resource_ids
  bindings         = each.value.bindings
  project          = each.value.project_id
}
