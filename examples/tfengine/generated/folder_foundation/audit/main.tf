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
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "audit"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 8.1.0"

  name                    = "example-audit"
  org_id                  = ""
  folder_id               = "12345678"
  billing_account         = "000-000-000"
  lien                    = true
  default_service_account = "keep"
  skip_gcloud_download    = true
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

# BigQuery log sink.
resource "google_logging_folder_sink" "bigquery_audit_logs_sink" {
  name             = "bigquery-audit-logs-sink"
  folder           = var.folder
  include_children = true
  filter           = "logName:\"logs/cloudaudit.googleapis.com\""
  destination      = "bigquery.googleapis.com/projects/${module.project.project_id}/datasets/${module.bigquery_destination.bigquery_dataset.dataset_id}"
}

module "bigquery_destination" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.3.0"

  dataset_id                  = "1yr_org_audit_logs"
  project_id                  = module.project.project_id
  location                    = "us-east1"
  default_table_expiration_ms = 365 * 8.64 * pow(10, 7) # 365 days
  access = [
    {
      role          = "roles/bigquery.dataOwner",
      special_group = "projectOwners"
    },
    {
      role           = "roles/bigquery.dataViewer",
      group_by_email = var.auditors_group
    },
  ]
}

resource "google_project_iam_member" "bigquery_sink_member" {
  project = module.bigquery_destination.bigquery_dataset.project
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_folder_sink.bigquery_audit_logs_sink.writer_identity
}

# Cloud Storage log sink.
resource "google_logging_folder_sink" "storage_audit_logs_sink" {
  name             = "storage-audit-logs-sink"
  folder           = var.folder
  include_children = true
  filter           = "logName:\"logs/cloudaudit.googleapis.com\""
  destination      = "storage.googleapis.com/${module.storage_destination.bucket.name}"
}

module "storage_destination" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.6.0"

  name          = "7yr-org-audit-logs"
  project_id    = module.project.project_id
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
      member = "group:${var.auditors_group}"
    },
  ]
}

# Deploy sink member as separate resource otherwise Terraform will return error:
# `The "for_each" value depends on resource attributes that cannot be determined
# until apply, so Terraform cannot predict how many instances will be created.`
resource "google_storage_bucket_iam_member" "storage_sink_member" {
  bucket = module.storage_destination.bucket.name
  role   = "roles/storage.objectCreator"
  member = google_logging_folder_sink.storage_audit_logs_sink.writer_identity
}

# IAM permissions to grant log Auditors iam.securityReviewer role to view the logs.
resource "google_folder_iam_member" "security_reviewer_auditors" {
  folder = var.folder
  role   = "roles/iam.securityReviewer"
  member = "group:${var.auditors_group}"
}
