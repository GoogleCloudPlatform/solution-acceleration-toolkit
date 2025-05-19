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
    google      = ">=3.0, <= 6"
    google-beta = "<= 6"
    kubernetes  = "~> 2.10"
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
  version = "~> 18.0.0"

  name            = "example-audit"
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
  activate_apis = [
    "bigquery.googleapis.com",
    "logging.googleapis.com",
  ]
}


# IAM Audit log configs to enable collection of all possible audit logs.
resource "google_folder_iam_audit_config" "config" {
  folder  = var.folder
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
  version = "~> 11.0.0"

  log_sink_name          = "example-bigquery-audit-logs-sink"
  destination_uri        = module.bigquery_destination.destination_uri
  filter                 = "logName:\"logs/cloudaudit.googleapis.com\" OR logName=\"logs/application\""
  parent_resource_type   = "folder"
  parent_resource_id     = var.folder
  unique_writer_identity = true
  include_children       = true
}

module "bigquery_destination" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 11.0.0"

  dataset_name             = "1yr_folder_audit_logs"
  project_id               = module.project.project_id
  location                 = "us-east1"
  log_sink_writer_identity = module.bigquery_export.writer_identity
  expiration_days          = 365
}

module "storage_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 11.0.0"

  log_sink_name          = "example-storage-audit-logs-sink"
  destination_uri        = module.storage_destination.destination_uri
  filter                 = "logName:\"logs/cloudaudit.googleapis.com\" OR logName=\"logs/application\""
  parent_resource_type   = "folder"
  parent_resource_id     = var.folder
  unique_writer_identity = true
  include_children       = true
}

// 6 years minimum audit log retention is required for HIPAA alignment.
// Thus, we lock retention policy to be at least 6 years
// and set the actual expiry to be greater than this amount (7 years).
module "storage_destination" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 11.0.0"

  storage_bucket_name      = "7yr-folder-audit-logs"
  project_id               = module.project.project_id
  location                 = "us-central1"
  log_sink_writer_identity = module.storage_export.writer_identity
  storage_class            = "COLDLINE"
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age        = 7 * 365
        with_state = "ANY"
      }
    }
  ]
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
resource "google_folder_iam_member" "security_reviewer_auditors" {
  folder = var.folder
  role   = "roles/iam.securityReviewer"
  member = "group:${var.auditors_group}"
}
