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

variable "skip" {
  type        = boolean
  description = "Whether or not create module resources."
}

variable "project_id" {
  type        = string
  description = "ID of project to deploy CICD in."
}

variable "trigger_type" {
  type = string
  description = <<EOF
    Trigger type used as suffix for naming purposes.
    It can be 'validate', 'plan', or 'apply'.
  EOF
}

variable "name" {
  type = string
  description = "Name of the scheduler job."
}

variable "scheduler_region" {
  type        = string
  description = "Region where the scheduler job (or the App Engine App behind the sceneces) resides. Must be specified if any triggers are configured to be run on schedule."
}

variable "run_on_schedule" {
  type = string
  description = "Whether or not to be automatically triggered according a specified schedule. The schedule is specified using unix-cron format at Eastern Standard Time (EST)."
}

variable "branch_name" {
  type = string
  description = <<EOF
    Name of the branch to set the Cloud Build Triggers to monitor.
    Regex is not supported to enforce a 1:1 mapping from a branch to a GCP environment.
  EOF
}
