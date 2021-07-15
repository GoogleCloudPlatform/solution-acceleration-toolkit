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

variable "org_id" {
  type        = string
  description = "ID of the organization to apply the configuration."
  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.org_id))
    error_message = "The org_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization id."
  }
}

variable "auditors_group" {
  type        = string
  description = "This group will be granted viewer access to the audit log dataset and bucket as well as security reviewer permission on the root resource specified."
}

variable "additional_filters" {
  type        = list(string)
  description = <<EOF
    Additional filters for log collection and export. 
    List entries will be concatenated by "OR" operator. 
    Refer to https://cloud.google.com/logging/docs/view/query-library for query syntax. Need to escape \ and " to preserve them in the final filter strings. 
    See example usages under "examples/tfengine/".
    Logs with filter "logName:\"logs/cloudaudit.googleapis.com\"" is always enabled.
  EOF
  default     = []
}

variable "bigquery_location" {
  type        = string
  description = "Location of logs bigquery dataset."
}

variable "logs_bigquery_dataset" {
  type = object({
    dataset_id = string
    sink_name  = string
  })
  description = "Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity."
}

variable "logs_storage_bucket" {
  type = object({
    name      = string
    sink_name = string
  })
  description = "GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements."
}

variable "storage_location" {
  type        = string
  description = "Location of logs storage bucket."
}
