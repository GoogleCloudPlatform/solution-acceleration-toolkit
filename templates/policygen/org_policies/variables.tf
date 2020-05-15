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

variable "policy_for" {
  description = "Resource hierarchy node to apply the policy to: one of `organization`, `folder`, or `project`."
  type        = string
}

variable "node_id" {
  description = "Resource hierarchy node ID: one of organization ID, folder ID or project ID"
  type        = string
}

variable "allowed_policy_member_domains" {
  description = "The list of domains to allow users from, e.g. google.com. If not specified, iam.allowedPolicyMemberDomains constraint will deny all"
  default     = []
}

variable "allowed_shared_vpc_host_projects" {
  description = "The list of allowed shared VPC host projects. Each entry must be specified in the form: under:organizations/ORGANIZATION_ID, under:folders/FOLDER_ID, or projects/PROJECT_ID. If not specified, compute.restrictSharedVpcHostProjects constraint will deny all"
  default     = []
}

variable "allowed_trusted_image_projects" {
  description = "The list of projects that can be used for image storage and disk instantiation for Compute Engine. Each entry must be specified in the form: projects/PROJECT_ID. If not specified, compute.trustedImageProjects constraint will deny all"
  default     = []
}
