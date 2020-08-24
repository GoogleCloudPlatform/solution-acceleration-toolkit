# Copyright 2020 Google LLC
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

variable "billing_account" {
  type = string
}

variable "project_id" {
  description = "Project ID of the devops project to host CI/CD resources"
  type        = string
}

variable "state_bucket" {
  description = "Name of the Terraform state bucket"
  type        = string
}

variable "terraform_root" {
  description = "Path of the directory relative to the repo root containing the Terraform configs"
  default     = "."
}

variable "build_viewers" {
  type        = list(string)
  description = "List of IAM members to grant cloudbuild.builds.viewer role in the devops project to see CICD results"
  default     = []
}

