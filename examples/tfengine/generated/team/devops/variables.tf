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
    customer_id  = string
    description  = string
    display_name = string
    exists       = string
    id           = string
    owners       = list(string)
    managers     = list(string)
    members      = list(string)
  })
  description = <<EOF
    Group which will be given admin access to the folder or organization.

    Fields:

    * customer_id = Customer ID of the organization to create the group in.
See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
for how to obtain it.
    * description = Description of the group.
    * display_name = Display name of the group.
    * exists = Whether or not the group exists already. It will be created if not.
    * id = Email address of the group.
    * owners = Owners of the group.
  EOF
}

variable "billing_account" {
  type        = string
  description = "ID of billing account to associate projects with."
}

variable "parent_id" {
  type        = string
  description = <<EOF
ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.
See <https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy> to learn more about resource hierarchy.
EOF
  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.parent_id))
    error_message = "The parent_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

variable "parent_type" {
  type        = string
  description = <<EOF
Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'.
EOF
  validation {
    condition     = can(regex("^organization|folder$", var.parent_type))
    error_message = "The parent_type must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

variable "project" {
  type = object({
    apis = list(string)
    owners_group = object({
      customer_id  = string
      description  = string
      display_name = string
      exists       = string
      id           = string
      owners       = list(string)
      managers     = list(string)
      members      = list(string)
    })
    project_id = string
  })
  description = <<EOF
    Config for the project to host devops resources such as remote state and CICD.

    Fields:

    * apis = List of APIs enabled in the devops project.

NOTE: If a CICD is deployed within this project, then the APIs of
all resources managed by the CICD must be listed here
(even if the resources themselves are in different projects).
    * owners_group = Group which will be given owner access to the project.
NOTE: By default, the creating user will be the owner of the project.
However, this group will own the project going forward. Make sure to include
yourselve in the group,
    ** customer_id = Customer ID of the organization to create the group in.
See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
for how to obtain it.
    ** description = Description of the group.
    ** display_name = Display name of the group.
    ** exists = Whether or not the group exists already. It will be created if not.
    ** id = Email address of the group.
    ** owners = Owners of the group.
    * project_id = ID of project.
  EOF
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project.project_id))
    error_message = "Invalid project.project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  }
}

variable "state_bucket" {
  type        = string
  description = "Name of the state bucket."
}

variable "storage_location" {
  type        = string
  description = "Location of state bucket."
}
