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
{{$csrProps := $props.cloud_source_repository.properties -}}
{{$githubProps := $props.github.properties -}}
{{$envsProps := $props.envs.items.properties -}}
{{$triggerProps := $envsProps.triggers.properties -}}
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
    error_message = "The parent_type must be valid. Should be either folder or organization."
  }
}

variable "build_editors" {
  type = list(string)
  description = {{schemaDescription $props.build_editors.description}}
  default = {{$props.build_editors.default}}
}

variable "build_viewers" {
  type = list(string)
  description = {{schemaDescription $props.build_viewers.description}}
  default = {{$props.build_viewers.default}}
}

variable "billing_account" {
  type = string
  description = {{schemaDescription $props.billing_account.description}}
}

{{- if has . "cloud_source_repository"}}

variable "cloud_source_repository" {
  type = object({
    name = string
    readers = list(string)
    writers = list(string)
  })
  description = <<EOF
    {{$props.cloud_source_repository.description}}

    Fields:

    * name = {{$csrProps.name.description}}
    * readers = {{$csrProps.readers.description}}
    * writers = {{$csrProps.writers.description}}
  EOF
}
{{- end}}

{{- if has . "github"}}

variable "github" {
  type = object({
    owner = string
    name = string
  })
  description = <<EOF
    {{$props.github.description}}

    Fields:

    * owner = {{$githubProps.owner.description}}
    * name = {{$githubProps.name.description}}
  EOF
}
{{- end}}

variable "envs" {
  type = list(object({
    branch_name = string 
    managed_dirs = string
    name = string
    triggers = object({
      apply = object({
        skip = bool
        run_on_push = bool
        run_on_schedule = string
      })
      plan = object({
        skip = bool
        run_on_push = bool
        run_on_schedule = string
      })
      validate = object({
        skip = bool
        run_on_push = bool
        run_on_schedule = string
      })
    })
  }))
  description = <<EOF
    {{schemaDescription $props.envs.description}}
  
    Fields:

    * branch_name = {{$envsProps.branch_name.description}} 
    * managed_dirs = {{$envsProps.managed_dirs.description}} 
    * name = {{$envsProps.name.description}} 
    * triggers = {{$envsProps.triggers.description}} 
    ** apply = {{$triggerProps.apply.description}}
    *** skip = Whether or not to skip creating trigger resources.
    *** run_on_push = {{$triggerProps.apply.properties.run_on_push.description}}
    *** run_on_schedule = {{$triggerProps.apply.properties.run_on_schedule.description}}
    ** plan = {{$triggerProps.plan.description}}
    *** skip = Whether or not to skip creating trigger resources.
    *** run_on_push = {{$triggerProps.plan.properties.run_on_push.description}}
    *** run_on_schedule = {{$triggerProps.plan.properties.run_on_schedule.description}}
    ** validate = {{$triggerProps.validate.description}}
    *** skip = Whether or not to skip creating trigger resources.
    *** run_on_push = {{$triggerProps.validate.properties.run_on_push.description}}
    *** run_on_schedule = {{$triggerProps.validate.properties.run_on_schedule.description}}
  EOF
}

variable "grant_automation_billing_user_role" {
  type        = bool
  description = {{schemaDescription $props.grant_automation_billing_user_role.description}}
  default     = {{$props.grant_automation_billing_user_role.default}}
}

variable "project_id" {
  type        = string
  description = {{schemaDescription $props.project_id.description}}
  validation {
    condition     = can(regex("{{terraformPattern $props.project_id}}", var.project_id))
    error_message = "The project_id must be valid. The project ID must be a unique string of 6 to 30 lowercase letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin for more information about project id format."
  }
}

variable "scheduler_region" {
  type        = string
  description = {{schemaDescription $props.scheduler_region.description}}
}

variable "state_bucket" {
  type        = string
  description = "Name of the Terraform state bucket."
}

variable "terraform_root" {
  type = string
  description = {{schemaDescription $props.terraform_root.description}}
}
