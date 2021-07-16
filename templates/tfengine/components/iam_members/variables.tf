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
  description = "IAM members for sotrage buckets."
  default = {}
}

variable "project_iam_members" {
  description = "IAM members for projects."
  default = {}
}

variable "folder_iam_members" {
  description = "IAM members for folders."
  default = {}
}

variable "organization_iam_members" {
  description = "IAM members for organizations."
  default = {}
}

variable "service_account_iam_members" {
  description = "IAM members for service accounts."
  default = {}
}
