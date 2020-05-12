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

variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "region" {
  description = "The region where the subnets will be created"
  default     = "us-central1"
  type        = string
}

variable "network_name" {
  description = "The name of the network"
  type        = string
}
