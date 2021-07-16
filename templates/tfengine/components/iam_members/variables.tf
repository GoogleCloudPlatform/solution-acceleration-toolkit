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

variable "storage_bucket_iam_members" {
  description = "IAM members for storage buckets. Assigns IAM bindings to a list of storage bucket names."
  default     = {}
  type        = map(object({
    resource_ids = list(string)
    bindings     = map(list(string))
  }))
}

variable "project_iam_members" {
  description = "IAM members for projects. Assigns IAM bindings to a list of project IDs."
  default     = {}
  type        = map(object({
    resource_ids = list(string)
    bindings     = map(list(string))
  }))
}

variable "folder_iam_members" {
  description = "IAM members for folders. Assigns IAM bindings to a list of folder IDs."
  default     = {}
  type        = map(object({
    resource_ids = list(string)
    bindings     = map(list(string))
  }))
}

variable "organization_iam_members" {
  description = "IAM members for organizations. Assigns IAM bindings to a list of organization IDs."
  default     = {}
  type        = map(object({
    resource_ids = list(string)
    bindings     = map(list(string))
  }))
}
