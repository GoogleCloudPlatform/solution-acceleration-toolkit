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

terraform {
  required_version = ">=0.13"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "dev/data"
  }
}

data "terraform_remote_state" "folders" {
  backend = "gcs"
  config = {
    bucket = "example-terraform-state"
    prefix = "folders"
  }
}
# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0.2"

  name            = "example-data-dev"
  org_id          = ""
  folder_id       = data.terraform_remote_state.folders.outputs.folder_ids["dev"]
  billing_account = "000-000-000"
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create the additional project-service-account@example-data-dev.iam.gserviceaccount.com service account.
  create_project_sa = false
  activate_apis     = ["compute.googleapis.com"]
}



module "example_bucket_dev" {
  source     = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version    = "~> 1.4"
  name       = "example-bucket-dev"
  project_id = module.project.project_id
  location   = "us-central1"

  labels = {
    env = "dev"
  }
}
