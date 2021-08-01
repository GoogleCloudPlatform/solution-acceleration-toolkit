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
variable "billing_account" {
  type        = string
  description = "ID of billing account to attach to this project."
}

variable "parent_id" {
  type        = string
  description = "ID of the parent GCP resource to apply the configuration."
  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.parent_id))
    error_message = "The parent_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}


variable "parent_type" {
  type        = string
  description = <<EOF
Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'."
EOF
  validation {
    condition     = can(regex("^organization|folder$", var.parent_type))
    error_message = "The parent_type must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

variable "api_identities" {
  type = list(object({
    api   = string
    roles = list(string)
  }))
  description = <<EOF
    The list of service identities (Google Managed service account for the API) to
force-create for the project (e.g. in order to grant additional roles).
APIs in this list will automatically be appended to `apis`.
Not including the API in this list will follow the default behaviour for identity
creation (which is usually when the first resource using the API is created).
Any roles (e.g. service agent role) must be explicitly listed.
See <https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles>
for a list of related roles.

    * api = The API whose default Service Agent will be force-created and granted the roles. Example: healthcare.googleapis.com.
    * roles = Roles to granted to the API Service Agent.
  EOF
  default     = []
}

variable "apis" {
  type        = list(string)
  description = "APIs to enable in the project."
  default     = []
}

variable "exists" {
  type        = bool
  description = "Whether this project exists."
  default     = false
}

variable "is_shared_vpc_host" {
  type        = bool
  description = "Whether this project is a shared VPC host."
  default     = false
}

variable "project_id" {
  type        = string
  description = "ID of project."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Invalid project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  }
}

variable "shared_vpc_attachment" {
  type = object({
    host_project_id = string
    subnets         = list(string)
  })
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.shared_vpc_attachment.host_project_id))
    error_message = "Invalid shared_vpc_attachment.host_project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  }
  description = <<EOF
    If set, treats this project as a shared VPC service project.
    
    * host_project_id = ID of host project to connect this project to. 
    * subnets = Subnets within the host project to grant this project access to. 
  EOF
}
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

variable "folder" {
  type        = string
  description = "ID of the parent GCP resource to apply the configuration."
  validation {
    condition     = can(regex("^folders/[0-9]{8,25}$", var.folder))
    error_message = "The folder must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your folder id."
  }
}

variable "auditors_group" {
  type        = string
  description = <<EOF
This group will be granted viewer access to the audit log dataset and
bucket as well as security reviewer permission on the root resource
specified.
EOF
}

variable "additional_filters" {
  type        = list(string)
  description = <<EOF
Additional filters for log collection and export. List entries will be
concatenated by "OR" operator. Refer to
<https://cloud.google.com/logging/docs/view/query-library> for query syntax.
Need to escape \ and " to preserve them in the final filter strings.
See example usages under "examples/tfengine/".
Logs with filter `"logName:\"logs/cloudaudit.googleapis.com\""` is always enabled.
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
