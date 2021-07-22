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

variable "branch_name" {
  type        = string
  description = <<EOF
    Name of the branch to set the Cloud Build Triggers to monitor.
    Regex is not supported to enforce a 1:1 mapping from a branch to a GCP environment.
  EOF
}

variable "managed_dirs" {
  type        = list(string)
  description = <<EOF
    List of root modules managed by the CICD relative to terraform_root.

    NOTE: The modules will be deployed in the given order. If a module depends on another module, it should show up after it in this list.

    NOTE: The CICD has permission to update APIs within its own project. Thus, you can list the devops module as one of the managed modules. Other changes to the devops project or CICD pipelines must be deployed manually.
  EOF
}

variable "env" {
  type        = string
  description = "Name of the environment."
}

variable "skip" {
  type        = boolean
  description = "Whether or not to skip creating trigger resources."
}

variable "run_on_push" {
  type        = boolean
  description = "Whether or not to be automatically triggered from a PR/push to branch."
}

variable "run_on_schedule" {
  type        = string
  description = "Whether or not to be automatically triggered according a specified schedule. The schedule is specified using unix-cron format at Eastern Standard Time (EST)."
}

variable "cloud_source_repository" {
  type = object({
    name = string
  })
  description = <<EOF
    Config for Google Cloud Source Repository.

    IMPORTANT: Cloud Source Repositories does not support code review or presubmit runs. 
    If you set both plan and apply to run at the same time, they will conflict and may error out. 
    To get around this, for 'shared' and 'prod' environment, set 'apply' trigger to not 'run_on_push', and for other environments, do not specify the 'plan' trigger block and let 'apply' trigger 'run_on_push'.
  EOF 
}

variable "project_id" {
  type        = string
  description = "ID of project to deploy CICD in."
}

variable "scheduler_region" {
  type        = string
  description = "Region where the scheduler job (or the App Engine App behind the sceneces) resides. Must be specified if any triggers are configured to be run on schedule."
}

variable "terraform_root" {
  type        = string
  description = <<EOF
    Path of the directory relative to the repo root containing the Terraform configs. Do not include ending "/".
  EOF
}

variable "terraform_root_prefix" {
  type        = string
  description = <<EOF
    Path of the directory relative to the repo root containing the Terraform configs. 
    It includes ending "/" when terraform root is not "."
  EOF
}

variable "service_account_email" {
  type        = string
  description = "Email of the Cloud Scheduler service account."
}
