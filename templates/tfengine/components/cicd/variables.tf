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

variable "build_editors" {
  type = list(string)
  description = "IAM members to grant cloudbuild.builds.editor role in the devops project to see CICD results."
  default = []
}

variable "build_viewers" {
  type = list(string)
  description = "IAM members to grant cloudbuild.builds.viewer role in the devops project to see CICD results."
  default = []
}

variable "billing_account" {
  type = string
}

{{- if has . "cloud_source_repository"}}

variable "cloud_source_repository" {
  type = object({
    name = string
    {{- if has .cloud_source_repository "readers"}}
    readers = list(string)
    {{- end}}
    {{- if has .cloud_source_repository "writers"}}
    writers = list(string)
    {{- end}}
  })
  description = <<EOF
    Config for Google Cloud Source Repository.

    IMPORTANT: Cloud Source Repositories does not support code review or presubmit runs. 
    If you set both plan and apply to run at the same time, they will conflict and may error out. 
    To get around this, for 'shared' and 'prod' environment, set 'apply' trigger to not 'run_on_push', and for other environments, do not specify the 'plan' trigger block and let 'apply' trigger 'run_on_push'.
  EOF 
}
{{- end}}

variable "envs" {
  type = list(object({
    branch_name = string 
    managed_dirs = list(string)
    name = string
    triggers = object({
      apply = object({
        skip = boolean
        run_on_push = boolean
        run_on_schedule = string
      })
      plan = object({
        skip = boolean
        run_on_push = boolean
        run_on_schedule = string
      })
      validate = object({
        skip = boolean
        run_on_push = boolean
        run_on_schedule = string
      })
    })
  }))
  description = "Config block for per-environment resources."
}

{{- if has . "github"}}

variable "github" {
  type = object({
    owner = string
    name = string
  })
  description = "Config for GitHub Cloud Build triggers."
}
{{- end}}

variable "project_id" {
  type        = string
  description = "ID of project to deploy CICD in."
}

variable "scheduler_region" {
  type        = string
  description = "Region where the scheduler job (or the App Engine App behind the sceneces) resides. Must be specified if any triggers are configured to be run on schedule."
}

variable "state_bucket" {
  type        = string
  description = "Name of the Terraform state bucket."
}

variable "terraform_root" {
  type = string
  description = <<EOF
    Path of the directory relative to the repo root containing the Terraform configs. Do not include ending "/".
  EOF
}

variable "terraform_root_prefix" {
  type = string
}
