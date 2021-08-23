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

variable "command" {
  type        = string
  description = "Terraform command to execute within this trigger."
  validation {
    condition     = can(regex("^validate|apply|plan$", var.command))
    error_message = "The provided command should be one of validate, apply or plan."
  }
}

variable "push" {
  type = object({
    skip     = bool
    disabled = bool
  })
  description = <<EOF
    Special options to specify for push trigger.

    Fields:

    * skip = Whether or not to create the push trigger.
    * disabled = If created, whether or not to disable it on push events.
  EOF
}

variable "scheduled" {
  type = object({
    skip     = bool
    disabled = bool
  })
  description = <<EOF
    Special options to specify for scheduled trigger.

    Fields:

    * skip = Whether or not to create the scheduled trigger.
    * disabled = If created, whether or not to disable it on push events.
  EOF
}

variable "branch_name" {
  type        = string
  description = <<EOF
Name of the branch to set the Cloud Build Triggers to monitor.
Regex is not supported to enforce a 1:1 mapping from a branch to a GCP
environment.
EOF
}

variable "managed_dirs" {
  type        = string
  description = <<EOF
List of root modules managed by the CICD relative to `terraform_root`.

NOTE: The modules will be deployed in the given order. If a module
depends on another module, it should show up after it in this list.
EOF
}

variable "env" {
  type        = string
  description = "Name of the environment."
}

variable "run_on_schedule" {
  type        = string
  description = <<EOF
Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST).
EOF
  default     = ""
}

variable "cloud_source_repository" {
  type = object({
    name = string
  })
  description = <<EOF
    Config for Google Cloud Source Repository.

IMPORTANT: Cloud Source Repositories does not support code review or
presubmit runs. If you set both plan and apply to run at the same time,
they will conflict and may error out. To get around this, for 'shared'
and 'prod' environment, set 'apply' trigger to not 'run_on_push',
and for other environments, do not specify the 'plan' trigger block
and let 'apply' trigger 'run_on_push'.

IMPORTANT: Only specify one of github or cloud_source_repository since
triggers should only respond to one of them, but not both. In case both are provided,
Github will receive priority.

    Fields:

    * name = Cloud Source Repository repo name.
The Cloud Source Repository should be hosted under the devops project.
  EOF
  default = {
    name = ""
  }
}

variable "github" {
  type = object({
    owner = string
    name  = string
  })
  description = <<EOF
    Config for GitHub Cloud Build triggers.

IMPORTANT: Only specify one of github or cloud_source_repository since
triggers should only respond to one of them, but not both. In case both are provided,
Github will receive priority.

    Fields:

    * owner = GitHub repo owner.
    * name = GitHub repo name.
  EOF
  default = {
    owner = ""
    name  = ""
  }
}

variable "project_id" {
  type        = string
  description = "ID of project to deploy CICD in."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id must be valid. The project ID must be a unique string of 6 to 30 lowercase letters, digits, or hyphens. It must start with a letter, and cannot have a trailing hyphen. See https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin for more information about project id format."
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

variable "terraform_root" {
  type        = string
  description = <<EOF
Path of the directory relative to the repo root containing the Terraform configs.
Do not include ending "/".
EOF
}

variable "service_account_email" {
  type        = string
  description = "Email of the Cloud Scheduler service account."
}
