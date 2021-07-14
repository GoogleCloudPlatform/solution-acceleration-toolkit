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
  type = string
}

variable "managed_dirs" {
  type = list(string)
}

variable "skip" {
  type = string
}

variable "create" {
  type = boolean
}

variable "run_on_push" {
  type = boolean
}

variable "run_on_schedule" {
  type = string
}

{{- if has . "cloud_source_repository"}}

variable "cloud_source_repository" {
  type = object({
    name = string
  })
}
{{- end}}

{{- if has . "github"}}

variable "github" {
  type = object({
    owner = string
    name = string
  })
}
{{- end}}

variable "project_id" {
  type        = string
  description = "Project ID of the devops project to host CI/CD resources."
}

variable "scheduler_region" {
  type        = string
}

variable "terraform_root" {
  type = string
}

variable "terraform_root_prefix" {
  type = string
}
