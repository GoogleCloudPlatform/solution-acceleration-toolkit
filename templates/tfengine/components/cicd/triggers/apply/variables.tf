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
{{$envProps := $props.envs.items.properties -}}
{{$triggerProps := $envProps.triggers.properties -}}
variable "branch_name" {
  type = string
  description = {{schemaDescription $envProps.branch_name.description}}
}

variable "managed_dirs" {
  type = string
  description = {{schemaDescription $envProps.managed_dirs.description}}
}

variable "env" {
  type = string
  description = {{schemaDescription $envProps.name.description}}
}

variable "skip" {
  type = bool
  description = "Whether or not to skip creating trigger resources."
}

variable "run_on_push" {
  type = bool
  description = {{schemaDescription $triggerProps.apply.properties.run_on_push.description}}
  default     = {{$triggerProps.apply.properties.run_on_push.default}}
}

variable "run_on_schedule" {
  type = string
  description = {{schemaDescription $triggerProps.apply.properties.run_on_schedule.description}}
  default     = {{$triggerProps.apply.properties.run_on_schedule.default}}
}

{{- if has . "cloud_source_repository"}}

variable "cloud_source_repository" {
  type = object({
    name = string
  })
  description = {{schemaDescription $props.cloud_source_repository.description}}
}
{{- end}}

{{- if has . "github"}}

variable "github" {
  type = object({
    owner = string
    name = string
  })
  description = {{schemaDescription $props.github.description}}
}
{{- end}}

variable "project_id" {
  type        = string
  description = {{schemaDescription $props.project_id.description}}
  validation {
    condition     = can(regex("{{replace $props.project_id.pattern "\\" ""}}", var.project_id))
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

variable "terraform_root_prefix" {
  type = string
  description = <<EOF
    Path of the directory relative to the repo root containing the Terraform configs. 
    It includes ending "/" when terraform root is not "."
  EOF
}

variable "service_account_email" {
  type = string
  description = "Email of the Cloud Scheduler service account."
}
