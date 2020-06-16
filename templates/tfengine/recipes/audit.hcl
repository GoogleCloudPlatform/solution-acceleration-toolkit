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
  title = "Org Audit Recipe"
  required = [
    "project_id",
    "dataset_name",
    "bucket_name",
    "auditors",
    "bigquery_location",
    "storage_location",
  ]
  properties = {
    project_id = {
      description = "ID of the project to host audit resources."
      type        = "string"
    }
    dataset_name = {
      description = "Name of the Bigquery Dataset to store 1 year audit logs."
      type        = "string"
    }
    bucket_name = {
      description = "Name of GCS Bucket to store 7 year audit logs."
      type        = "string"
    }
    auditors = {
      description = <<EOF
        This group will be granted viewer access to the audit log dataset and
        bucket as well as security reviewer permission on the root resource
        specified.
      EOF
      type        = "string"
      pattern     = "group:.+"
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
  output_path = "./audit"
  data = {
    project = {
      project_id = "{{.project_id}}"
      apis = [
        "bigquery.googleapis.com",
        "logging.googleapis.com",
      ]
    }
  }
}

template "audit" {
  component_path = "../components/org/audit"
  output_path    = "./audit/resources"
}
