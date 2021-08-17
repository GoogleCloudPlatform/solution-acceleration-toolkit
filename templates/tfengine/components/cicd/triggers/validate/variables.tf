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
variable "branch_name" {
  type = string
  description = {{schemaDescription $envsProps.branch_name.description}}
}

variable "managed_dirs" {
  type = string
  description = {{schemaDescription $envsProps.managed_dirs.description}}
}

variable "env" {
  type = string
  description = {{schemaDescription $envsProps.name.description}}
}

variable "skip" {
  type = bool
  description = "Whether or not to skip creating trigger resources."
}

variable "run_on_push" {
  type = bool
  description = {{schemaDescription $triggerProps.validate.properties.run_on_push.description}}
  default     = {{$triggerProps.validate.properties.run_on_push.default}}
}

variable "run_on_schedule" {
  type = string
  description = {{schemaDescription $triggerProps.validate.properties.run_on_schedule.description}}
  default     = {{$triggerProps.validate.properties.run_on_schedule.default}}
}

{{- if has . "cloud_source_repository"}}

variable "cloud_source_repository" {
  type = object({
    name = string
  })
  description = <<EOF
    {{$props.cloud_source_repository.description}}

    Fields:

    * name = {{$csrProps.name.description}}
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

variable "terraform_root" {
  type = string
  description = {{schemaDescription $props.terraform_root.description}}
}

variable "service_account_email" {
  type = string
  description = "Email of the Cloud Scheduler service account."
}
