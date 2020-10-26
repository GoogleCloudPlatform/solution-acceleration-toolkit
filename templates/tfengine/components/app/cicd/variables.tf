{{- /* Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

variable "branch_name" {
  description = "Branch to trigger on"
  type        = string
  default     = "^main$"
}

variable "source_repo_name" {
  description = "Name of source repo that will be created in the devops project."
  type        = string
  default     = "configs"
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
