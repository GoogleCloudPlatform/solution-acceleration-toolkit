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
}

variable "build_viewers" {
  type = list(string)
}

variable "billing_account" {
  type = string
}

variable "github" {
  type = object({
    owner = string
    name  = string
  })
}

variable "project_id" {
  description = "Project ID of the devops project to host CI/CD resources"
  type        = string
}

variable "state_bucket" {
  description = "Name of the Terraform state bucket"
  type        = string
}
