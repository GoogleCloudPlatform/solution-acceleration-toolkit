# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

schema = {
  title                = "Audit Recipe"
  additionalProperties = false
  required = [
    "auditors_group",
    "logs_bigquery_dataset",
    "logs_storage_bucket"
  ]
  properties = {
    parent_type = {
      description = <<EOF
        Type of parent GCP resource to apply the policy.
        Must be one of 'organization' or 'folder'."
      EOF
      type        = "string"
      pattern     = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of the parent GCP resource to apply the configuration.
      EOF
      type        = "string"
      pattern     = "^[0-9]{8,25}$"
    }
    project = {
      description          = "Config of project to host auditing resources"
      type                 = "object"
      additionalProperties = false
      properties = {
        project_id = {
          description = "ID of project."
          type        = "string"
          pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
        }
      }
    }
    logs_bigquery_dataset = {
      description          = "Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity."
      type                 = "object"
      additionalProperties = false
      required = [
        "dataset_id"
      ]
      properties = {
        dataset_id = {
          description = "ID of Bigquery Dataset."
          type        = "string"
        }
        sink_name = {
          description = <<EOF
            Name of the logs sink.
          EOF
          type        = "string"
          default     = "bigquery-audit-logs-sink"
        }
      }
    }
    logs_storage_bucket = {
      description          = "GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements."
      type                 = "object"
      additionalProperties = false
      required = [
        "name"
      ]
      properties = {
        name = {
          description = "Name of GCS bucket."
          type        = "string"
        }
        sink_name = {
          description = <<EOF
            Name of the logs sink.
          EOF
          type        = "string"
          default     = "storage-audit-logs-sink"
        }
      }
    }
    auditors_group = {
      description = <<EOF
        This group will be granted viewer access to the audit log dataset and
        bucket as well as security reviewer permission on the root resource
        specified.
      EOF
      type        = "string"
    }
    bigquery_location = {
      description = "Location of logs bigquery dataset."
      type        = "string"
    }
    storage_location = {
      description = "Location of logs storage bucket."
      type        = "string"
    }
    additional_filters = {
      description = <<EOF
        Additional filters for log collection and export. List entries will be
        concatenated by "OR" operator. Refer to
        <https://cloud.google.com/logging/docs/view/query-library> for query syntax.
        Need to escape \ and " to preserve them in the final filter strings.
        See example usages under "examples/tfengine/".
        Logs with filter `"logName:\"logs/cloudaudit.googleapis.com\""` is always enabled.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
      default = "[]"
    }
  }
}

template "project" {
  recipe_path = "./project.hcl"
  data = {
    project = {
      project_id = {{hcl .project.project_id}}
      apis = [
        "bigquery.googleapis.com",
        "logging.googleapis.com",
      ]
    }
  }
}

template "audit" {
  component_path = "../components/audit"
}
