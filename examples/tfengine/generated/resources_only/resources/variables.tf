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
  description = <<EOF
ID of parent GCP resource to apply the policy
Can be one of the organization ID or folder ID according to parent_type.
EOF
  validation {
    condition     = can(regex("", var.parent_id))
    error_message = "The parent_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}


variable "parent_type" {
  type        = string
  description = <<EOF
Type of parent GCP resource to apply the policy
Can be one of 'organization' or 'folder'.
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

    Fields:

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
  description = "ID of project to create and/or provision resources in."
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
    
    Fields:

    * host_project_id = ID of host project to connect this project to. 
    * subnets = Subnets within the host project to grant this project access to. 
  EOF
}
