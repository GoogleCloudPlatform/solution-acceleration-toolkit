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

{{$props := .__schema__.properties -}}
{{if eq .parent_type "organization" -}}
variable "org_id" {
  type = string
  description = {{schemaDescription $props.parent_id.description}}
  validation {
    condition     = can(regex("{{$props.parent_id.pattern}}", var.org_id))
    error_message = "The org_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization id."
  }
}
{{- else -}}
variable "folder" {
  type = string
  description = {{schemaDescription $props.parent_id.description}}
  validation {
    condition     = can(regex("{{replace $props.parent_id.pattern "^" "^folders/"}}", var.folder))
    error_message = "The folder must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your folder id."
  }
}
{{- end}}

variable "auditors_group" {
  type = string
  description = {{schemaDescription $props.auditors_group.description}}
}

variable "additional_filters" {
  type = list(string)
  description = {{schemaDescription $props.additional_filters.description}}
  default = {{$props.additional_filters.default}}
}

variable "bigquery_location" {
  type = string
  description = {{schemaDescription $props.bigquery_location.description}}
}

variable "logs_bigquery_dataset" {
  type = object({
    dataset_id = string
    sink_name = string
  })
  description = {{schemaDescription $props.logs_bigquery_dataset.description}}
}

variable "logs_storage_bucket" {
  type = object({
    name = string
    sink_name = string
  })
  description = {{schemaDescription $props.logs_storage_bucket.description}}
}

variable "storage_location" {
  type = string
  description = {{schemaDescription $props.storage_location.description}}
}
