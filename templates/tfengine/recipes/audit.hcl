# Copyright 2020 Google LLC
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
        ID of parent GCP resource to apply the policy.
        Can be one of the organization ID or folder ID according to parent_type.
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
        }
      }
    }
    logs_bigquery_dataset = {
      description          = "Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity."
      type                 = "object"
      additionalProperties = false
      properties = {
        dataset_id = {
          description = "ID of Bigquery Dataset."
          type        = "string"
        }
      }
    }
    logs_storage_bucket = {
      description          = "GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements."
      type                 = "object"
      additionalProperties = false
      properties = {
        name = {
          description = "Name of GCS bucket."
          type        = "string"
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
  }
}

template "project" {
  recipe_path = "./project.hcl"
  data = {
    project = {
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
