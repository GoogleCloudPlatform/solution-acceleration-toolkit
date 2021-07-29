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
  type        = list(string)
  description = <<EOF
IAM members to grant `cloudbuild.builds.editor` role in the devops project
to see CICD results.
EOF
  default     = []
}

variable "build_viewers" {
  type        = list(string)
  description = <<EOF
IAM members to grant `cloudbuild.builds.viewer` role in the devops project
to see CICD results.
EOF
  default     = []
}

variable "billing_account" {
  type = string
}

variable "github" {
  type = object({
    owner = string
    name  = string
  })
  description = "Config for GitHub Cloud Build triggers."
}

variable "envs" {
  type = list(object({
    branch_name  = string
    managed_dirs = string
    name         = string
    triggers = object({
      apply = object({
        skip            = bool
        run_on_push     = bool
        run_on_schedule = string
      })
      plan = object({
        skip            = bool
        run_on_push     = bool
        run_on_schedule = string
      })
      validate = object({
        skip            = bool
        run_on_push     = bool
        run_on_schedule = string
      })
    })
  }))
  description = "Config block for per-environment resources."
}

variable "project_id" {
  type        = string
  description = "ID of project to deploy CICD in."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = <<EOF
      The project_id must be valid. The project ID must be a unique string of 6 to 30 lowercase letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin for more information about project id format.
    EOF
  }
}

variable "scheduler_region" {
  type        = string
  description = <<EOF
[Region](https://cloud.google.com/appengine/docs/locations) where the scheduler
job (or the App Engine App behind the sceneces) resides. Must be specified if
any triggers are configured to be run on schedule.
EOF
}

variable "state_bucket" {
  type        = string
  description = "Name of the Terraform state bucket."
}

variable "terraform_root" {
  type        = string
  description = <<EOF
Path of the directory relative to the repo root containing the Terraform configs.
Do not include ending "/".
EOF
}

variable "terraform_root_prefix" {
  type        = string
  description = <<EOF
    Path of the directory relative to the repo root containing the Terraform configs. 
    It includes ending "/" when terraform root is not "."
  EOF
}
