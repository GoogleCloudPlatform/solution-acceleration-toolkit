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

# This folder contains Terraform resources related to audit, which includes:
# - Organization IAM Audit log configs (https://cloud.google.com/logging/docs/audit),
# - BigQuery log sink creation and configuration for short term log storage,
# - Cloud Storage log sink creation and configuration for long term log storage,
# - IAM permissions to grant log Auditors iam.securityReviewer role to view the logs.

terraform {
  backend "gcs" {}
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

# BigQuery log sink.
resource "google_logging_organization_sink" "bigquery_audit_logs_sink" {
  name             = "bigquery-audit-logs-sink"
  org_id           = var.org_id
  include_children = true
  filter           = "logName:\"logs/cloudaudit.googleapis.com\""
  destination      = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${module.bigquery_destination.bigquery_dataset.dataset_id}"
}

module "bigquery_destination" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.1.0"

  dataset_id                  = "1yr_org_audit_logs"
  project_id                  = var.project_id
  location                    = "us-east1"
  default_table_expiration_ms = 365 * 8.64 * pow(10, 7) # 365 days
  access = [
    {
      role          = "roles/bigquery.dataOwner",
      special_group = "projectOwners"
    },
    {
      role           = "roles/bigquery.dataViewer",
      group_by_email = trimprefix(var.auditors, "group:")
    },
  ]
}

resource "google_project_iam_member" "bigquery_sink_member" {
  project = module.bigquery_destination.bigquery_dataset.project
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_organization_sink.bigquery_audit_logs_sink.writer_identity
}

# Cloud Storage log sink.
resource "google_logging_organization_sink" "storage_audit_logs_sink" {
  name             = "storage-audit-logs-sink"
  org_id           = var.org_id
  include_children = true
  filter           = "logName:\"logs/cloudaudit.googleapis.com\""
  destination      = "storage.googleapis.com/${module.storage_destination.bucket.name}"
}

module "storage_destination" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.6.0"

  name          = "7yr-org-audit-logs"
  project_id    = var.project_id
  location      = "us-central1"
  storage_class = "COLDLINE"

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age        = 7 * 365 # 7 years
      with_state = "ANY"
    }
  }]

  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = var.auditors
    },
  ]
}

# Deploy sink member as separate resource otherwise Terraform will return error:
# `The "for_each" value depends on resource attributes that cannot be determined
# until apply, so Terraform cannot predict how many instances will be created.`
resource "google_storage_bucket_iam_member" "storage_sink_member" {
  bucket = module.storage_destination.bucket.name
  role   = "roles/storage.objectCreator"
  member = google_logging_organization_sink.storage_audit_logs_sink.writer_identity
}

# IAM permissions to grant log Auditors iam.securityReviewer role to view the logs.
resource "google_organization_iam_member" "security_reviewer_auditors" {
  org_id = var.org_id
  role   = "roles/iam.securityReviewer"
  member = var.auditors
}
