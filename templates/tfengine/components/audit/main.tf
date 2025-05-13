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

{{- $parent_field := "org_id"}}
{{- $parent_var := "var.org_id"}}
{{- if eq .parent_type "folder"}}
  {{- $parent_field = "folder"}}
  {{- $parent_var = "var.folder"}}
{{- end}}

{{- $filter := `logName:\"logs/cloudaudit.googleapis.com\"`}}
{{- range get . "additional_filters"}}
{{- $filter = printf "%s OR %s" $filter .}}
{{- end}}

# IAM Audit log configs to enable collection of all possible audit logs.
resource "google_{{.parent_type}}_iam_audit_config" "config" {
  {{$parent_field}} = {{$parent_var}}
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

  log_sink_name          = "{{get .logs_bigquery_dataset "sink_name" "bigquery-audit-logs-sink"}}"
  destination_uri        = "${module.bigquery_destination.destination_uri}"
  filter                 = "{{$filter}}"
  parent_resource_type   = "{{.parent_type}}"
  parent_resource_id     = {{$parent_var}}
  unique_writer_identity = true
  include_children       = true
}

module "bigquery_destination" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 11.0.0"

  dataset_name             = "{{.logs_bigquery_dataset.dataset_id}}"
  project_id               = module.project.project_id
  location                 = "{{.bigquery_location}}"
  log_sink_writer_identity = "${module.bigquery_export.writer_identity}"
  expiration_days          = 365
}

module "storage_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 11.0.0"

  log_sink_name          = "{{get .logs_storage_bucket "sink_name" "storage-audit-logs-sink"}}"
  destination_uri        = "${module.storage_destination.destination_uri}"
  filter                 = "{{$filter}}"
  parent_resource_type   = "{{.parent_type}}"
  parent_resource_id     = {{$parent_var}}
  unique_writer_identity = true
  include_children       = true
}

// 6 years minimum audit log retention is required for HIPAA alignment.
// Thus, we lock retention policy to be at least 6 years
// and set the actual expiry to be greater than this amount (7 years).
module "storage_destination" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 11.0.0"

  storage_bucket_name      = "{{.logs_storage_bucket.name}}"
  project_id               = module.project.project_id
  location                 = "{{.storage_location}}"
  log_sink_writer_identity = "${module.storage_export.writer_identity}"
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
resource "google_{{.parent_type}}_iam_member" "security_reviewer_auditors" {
  {{$parent_field}} = {{$parent_var}}
  role   = "roles/iam.securityReviewer"
  member = "group:${var.auditors_group}"
}
