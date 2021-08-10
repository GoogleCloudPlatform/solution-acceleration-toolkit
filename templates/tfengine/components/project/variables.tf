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
{{$projectProps := $props.project.properties -}}
{{$apiIdentitiesProps := $projectProps.api_identities.items.properties -}}
{{$sharedVpcProps := $projectProps.shared_vpc_attachment.properties -}}
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
  default = ""
}


variable "parent_type" {
  type        = string
  description = {{schemaDescription $props.parent_type.description}}
  validation {
    condition     = can(regex("{{$props.parent_type.pattern}}", var.parent_type))
    error_message = "The parent_type must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

variable "api_identities" {
  type = list(object({
    api   = string
    roles = list(string)
  }))
  description = <<EOF
    {{$projectProps.api_identities.description}}

    Fields:

    * api = {{$apiIdentitiesProps.api.description}}
    * roles = {{$apiIdentitiesProps.roles.description}}
  EOF
  default     = {{$projectProps.api_identities.default}}
}

variable "apis" {
  type        = list(string)
  description = {{schemaDescription $projectProps.apis.description}}
  default     = {{$projectProps.apis.default}}
}

variable "exists" {
  type        = bool
  description = {{schemaDescription $projectProps.exists.description}}
  default     = {{$projectProps.exists.default}}
}

variable "is_shared_vpc_host" {
  type        = bool
  description = {{schemaDescription $projectProps.is_shared_vpc_host.description}}
  default     = {{$projectProps.is_shared_vpc_host.default}}
}

variable "project_id" {
  type        = string
  description = {{schemaDescription $projectProps.project_id.description}}
  validation {
    condition     = can(regex("{{replace $projectProps.project_id.pattern "\\" ""}}", var.project_id))
    error_message = "Invalid project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  }
}

variable "shared_vpc_attachment" {
  type = object({
    host_project_id = string
    subnets = list(string)
  })
  # TODO(#987): Uncomment when terraformPattern is implemented for this field
  # validation {
  #   condition     = can(regex("{{replace $sharedVpcProps.host_project_id.pattern "\\" ""}}", var.shared_vpc_attachment.host_project_id))
  #   error_message = "Invalid shared_vpc_attachment.host_project_id. Should be a string of 6 to 30 letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects."
  # }
  description = <<EOF
    {{$projectProps.shared_vpc_attachment.description}}
    
    Fields:

    * host_project_id = {{$sharedVpcProps.host_project_id.description}} 
    * subnets = {{$sharedVpcProps.subnets.description}} 
  EOF
}
