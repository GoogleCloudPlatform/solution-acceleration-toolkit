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

variable "parent_id" {
  type        = string
  description = "ID of the parent GCP resource to apply the configuration."
  validation {
    condition     = can(regex("^[0-9]{8,25}$", var.parent_id))
    error_message = "The parent_id must be valid. Should have only numeric values with a length between 8 and 25 digits. See https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy to know how to get your organization/folder id."
  }
}

variable "parent_type" {
  type        = string
  description = <<EOF
Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'."
EOF
  validation {
    condition     = can(regex("^organization|folder$", var.parent_type))
    error_message = "The parent_type must be valid. Should be either folder or organization."
  }
}

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
  type        = string
  description = "ID of billing account to attach to this project."
}

variable "cloud_source_repository" {
  type = object({
    name    = string
    readers = list(string)
    writers = list(string)
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
    * readers = IAM members to allow reading the repo.
    * writers = IAM members to allow writing to the repo.
  EOF
  default = {
    name    = ""
    readers = []
    writers = []
  }
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
  description = <<EOF
    "Config block for per-environment resources."
  
    Fields:

    * branch_name = Name of the branch to set the Cloud Build Triggers to monitor.
Regex is not supported to enforce a 1:1 mapping from a branch to a GCP
environment. 
    * managed_dirs = List of root modules managed by the CICD relative to `terraform_root`.

NOTE: The modules will be deployed in the given order. If a module
depends on another module, it should show up after it in this list. 
    * name = Name of the environment. 
    * triggers = Config block for the CICD Cloud Build triggers. 
      * apply = Config block for the postsubmit apply/deployyemt Cloud Build trigger.
If specified,create the trigger and grant the Cloud Build Service Account
necessary permissions to perform the build.
        * skip = Whether or not to skip creating trigger resources.
        * run_on_push = Whether or not to be automatically triggered from a PR/push to branch.
Default to true.
        * run_on_schedule = Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.
      * plan = Config block for the presubmit plan Cloud Build trigger.
If specified, create the trigger and grant the Cloud Build Service Account
necessary permissions to perform the build.
        * skip = Whether or not to skip creating trigger resources.
        * run_on_push = Whether or not to be automatically triggered from a PR/push to branch.
        * run_on_schedule = Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST).
      * validate = Config block for the presubmit validation Cloud Build trigger. If specified, create
the trigger and grant the Cloud Build Service Account necessary permissions to
perform the build.
        * skip = Whether or not to skip creating trigger resources.
        * run_on_push = Whether or not to be automatically triggered from a PR/push to branch.
        * run_on_schedule = Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST).
  EOF
}

variable "grant_automation_billing_user_role" {
  type        = bool
  description = <<EOF
Whether or not to grant automation service account the billing.user role.
Default to true.
EOF
  default     = true
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
