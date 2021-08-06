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
{{$adminsGroupProps := $props.admins_group.properties -}}
{{$projectProps := $props.project.properties -}}
{{$projectOwnersGroupProps := $projectProps.owners_group.properties -}}
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
    {{$props.admins_group.description}}

    Fields:

    * customer_id = {{$adminsGroupProps.customer_id.description}}
    * description = {{$adminsGroupProps.description.description}}
    * display_name = {{$adminsGroupProps.display_name.description}}
    * exists = {{$adminsGroupProps.exists.description}}
    * id = {{$adminsGroupProps.id.description}}
    * owners = {{$adminsGroupProps.owners.description}}
  EOF
}

variable "billing_account" {
  type        = string
  description = {{schemaDescription $props.billing_account.description}}
}

variable "parent_id" {
  type        = string
  description = {{schemaDescription $props.parent_id.description}}
  validation {
    condition     = can(regex("{{$props.parent_id.pattern}}", var.parent_id))
    error_message = "The parent_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

variable "parent_type" {
  type        = string
  description = {{schemaDescription $props.parent_type.description}}
  validation {
    condition     = can(regex("{{$props.parent_type.pattern}}", var.parent_type))
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
    {{$props.project.description}}

    Fields:

    * apis = {{$projectProps.apis.description}}
    * owners_group = {{$projectProps.owners_group.description}}
      * customer_id = {{$projectOwnersGroupProps.customer_id.description}}
      * description = {{$projectOwnersGroupProps.description.description}}
      * display_name = {{$projectOwnersGroupProps.display_name.description}}
      * exists = {{$projectOwnersGroupProps.exists.description}}
      * id = {{$projectOwnersGroupProps.id.description}}
      * owners = {{$projectOwnersGroupProps.owners.description}}
    * project_id = {{$projectProps.project_id.description}}
  EOF
  validation {
    condition     = can(regex("{{replace $props.project.properties.project_id.pattern "\\" ""}}", var.project.project_id))
    error_message = "Invalid project.project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  }
}

variable "state_bucket" {
  type        = string
  description = {{schemaDescription $props.state_bucket.description}}
}

variable "storage_location" {
  type        = string
  description = {{schemaDescription $props.storage_location.description}}
}
