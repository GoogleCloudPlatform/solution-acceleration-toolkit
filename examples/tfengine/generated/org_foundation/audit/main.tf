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
    prefix = "audit"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.1.0"

  count = var.exists ? 0 : 1

  name            = var.project_id
  org_id          = var.parent_type == "organization" ? var.parent_id : ""
  folder_id       = var.parent_type == "folder" ? var.parent_id : ""
  billing_account = var.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  enable_shared_vpc_host_project = var.is_shared_vpc_host

  svpc_host_project_id = var.shared_vpc_attachment.host_project_id
  shared_vpc_subnets   = var.shared_vpc_attachment.subnets
  activate_apis        = var.apis

  activate_api_identities = var.api_identities
}


# IAM Audit log configs to enable collection of all possible audit logs.
resource "google_organization_iam_audit_config" "config" {
  org_id  = var.org_id
  service = "allServices"

  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
  audit_log_config {
    log_type = "ADMIN_READ"
  }
}

module "bigquery_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 6.0.0"

  log_sink_name          = var.logs_bigquery_dataset.sink_name
  destination_uri        = module.bigquery_destination.destination_uri
  filter                 = join(" OR ", concat(["logName:\"logs/cloudaudit.googleapis.com\""], var.additional_filters))
  parent_resource_type   = "organization"
  parent_resource_id     = var.org_id
  unique_writer_identity = true
  include_children       = true
}

module "bigquery_destination" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 6.0.0"

  dataset_name             = var.logs_bigquery_dataset.dataset_id
  project_id               = module.project.project_id
  location                 = var.bigquery_location
  log_sink_writer_identity = module.bigquery_export.writer_identity
  expiration_days          = 365
}

module "storage_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 6.0.0"

  log_sink_name          = var.logs_storage_bucket.sink_name
  destination_uri        = module.storage_destination.destination_uri
  filter                 = join(" OR ", concat(["logName:\"logs/cloudaudit.googleapis.com\""], var.additional_filters))
  parent_resource_type   = "organization"
  parent_resource_id     = var.org_id
  unique_writer_identity = true
  include_children       = true
}

// 6 years minimum audit log retention is required for HIPAA alignment.
// Thus, we lock retention policy to be at least 6 years
// and set the actual expiry to be greater than this amount (7 years).
module "storage_destination" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 6.0.0"

  storage_bucket_name      = var.logs_storage_bucket.name
  project_id               = module.project.project_id
  location                 = var.storage_location
  log_sink_writer_identity = module.storage_export.writer_identity
  storage_class            = "COLDLINE"
  expiration_days          = 7 * 365
  retention_policy = {
    is_locked             = true
    retention_period_days = 6 * 365
  }
}

resource "google_project_iam_member" "logs_viewers_auditors" {
  for_each = toset([
    "roles/bigquery.user",
    "roles/storage.objectViewer",
  ])
  project = module.project.project_id
  role    = each.key
  member  = "group:${var.auditors_group}"
}

# IAM permissions to grant log Auditors iam.securityReviewer role to view the logs.
resource "google_organization_iam_member" "security_reviewer_auditors" {
  org_id = var.org_id
  role   = "roles/iam.securityReviewer"
  member = "group:${var.auditors_group}"
}
