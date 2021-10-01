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

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
    kubernetes  = "~> 2.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "folders"
  }
}

resource "google_folder" "dev" {
  display_name = "dev"
  parent       = "folders/12345678"
}
resource "google_folder" "prod" {
  display_name = "prod"
  parent       = "folders/12345678"
}
