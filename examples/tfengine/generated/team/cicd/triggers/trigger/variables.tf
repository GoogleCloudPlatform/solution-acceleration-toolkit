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

variable "filename" {
  type        = string
  description = <<EOF
    Name of the configuration file to execute on trigger.
    It should be located under ${var.terraform_root_prefix}/cicd/configs.
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

variable "name" {
  type        = string
  description = "Name of the trigger."
}

variable "description" {
  type        = string
  description = "Description of the trigger."
}

variable "skip" {
  type        = boolean
  description = "Whether or not create module resources."
}

variable "run_on_push" {
  type        = boolean
  description = "Whether or not to be automatically triggered from a PR/push to branch."
}

variable "github" {
  type = object({
    owner = string
    name  = string
  })
  description = "Config for GitHub Cloud Build triggers."
}

variable "project_id" {
  type        = string
  description = "ID of project to deploy CICD in."
}

variable "terraform_root" {
  type        = string
  description = <<EOF
    Path of the directory relative to the repo root containing the Terraform configs. Do not include ending "/".
  EOF
}

variable "terraform_root_prefix" {
  type = string
}
