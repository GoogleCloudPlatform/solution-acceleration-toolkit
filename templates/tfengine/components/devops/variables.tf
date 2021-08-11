{{- /* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}
{{$props := .__schema__.properties -}}
{{$missing_admins_group := not (get .admins_group "exists") -}}
variable "admins_group" {
  type = object({
    id           = string
    {{- if $missing_admins_group}}
    customer_id  = string
    display_name = string
    {{- if has .admins_group "description"}}
    description  = string
    {{- end}}
    {{- if has .admins_group "owners"}}
    owners       = list(string)
    {{- end}}
    {{- if has .admins_group "managers"}}
    managers     = list(string)
    {{- end}}
    {{- if has .admins_group "members"}}
    members      = list(string)
    {{- end}}
    {{- end}}
  })
  description = {{schemaDescription $props.admins_group.description}}
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

variable "project" {
  type = object({
    apis = list(string)
    owners_group = object({
      id           = string
      {{- $missing_project_owners_group := not (get .project.owners_group "exists")}}
      {{- if $missing_project_owners_group}}
      customer_id  = string
      display_name = string
      {{- if has .project.owners_group "description"}}
      description  = string
      {{- end}}
      {{- if has .project.owners_group "owners"}}
      owners       = list(string)
      {{- end}}
      {{- if has .project.owners_group "managers"}}
      managers     = list(string)
      {{- end}}
      {{- if has .project.owners_group "members"}}
      members      = list(string)
      {{- end}}
      {{- end}}
    })
    project_id = string
  })
  description = {{schemaDescription $props.project.description}}
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
