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
    google      = ">= 3.0"
    google-beta = ">= 3.0"
    kubernetes  = "~> 2.10"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "groups"
  }
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0.0"

  project_id    = "example-devops"
  activate_apis = []
}
# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = module.project.project_id
}


module "example_auditors_example_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.3"

  id           = "example-auditors@example.com"
  customer_id  = "c12345678"
  display_name = "Example Auditors Group"
  owners       = ["user1@example.com"]
}

module "example_cicd_viewers_example_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.3"

  id           = "example-cicd-viewers@example.com"
  customer_id  = "c12345678"
  display_name = "example-cicd-viewers"
}

module "example_cicd_editors_example_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.3"

  id           = "example-cicd-editors@example.com"
  customer_id  = "c12345678"
  display_name = "example-cicd-editors"
}

module "example_source_readers_example_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.3"

  id           = "example-source-readers@example.com"
  customer_id  = "c12345678"
  display_name = "example-source-readers"
}

module "example_source_writers_example_com" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.3"

  id           = "example-source-writers@example.com"
  customer_id  = "c12345678"
  display_name = "example-source-writers"
}
