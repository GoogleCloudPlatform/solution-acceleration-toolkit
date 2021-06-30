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

variable "admins_group" {
  type = object({
    id = string
  })
  description = "Group which will be given admin access to the folder or organization."
}

variable "billing_account" {
  type        = string
  description = "ID of billing account to attach to this project."
}

variable "parent_id" {
  type        = string
  description = "ID of parent GCP resource to apply the policy. Can be one of the organization ID or folder ID according to parent_type. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to learn more about resource hierarchy."
  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.parent_id))
    error_message = "The parent_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

# TODO(ernestognw): Test with private catalog and validate it 
# accepts nested data structures
variable "project" {
  type = object({
    apis = list(string)
    owners_group = object({
      id = string
    })
    project_id = string
  })
  description = "Config for the project to host devops resources such as remote state and CICD."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project.project_id))
    error_message = "Invalid project.project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  }
}

variable "state_bucket" {
  type        = string
  description = "Name of Terraform remote state bucket."
}

variable "storage_location" {
  type        = string
  description = "Location of state bucket."
}
