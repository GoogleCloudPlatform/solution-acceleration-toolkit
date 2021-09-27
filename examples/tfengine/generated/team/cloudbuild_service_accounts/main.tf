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
    kubernetes  = "~> 1.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "cloudbuild_service_accounts"
  }
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.1.0"

  project_id    = "example-prod-devops"
  activate_apis = []
}

module "project_iam_members" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 7.2.0"

  projects = [module.project.project_id]
  mode     = "additive"

  bindings = {
    "roles/iam.serviceAccountUser" = [
      "serviceAccount:${google_service_account.cloudbuild_sa.account_id}@example-prod-devops.iam.gserviceaccount.com",
    ],
    "roles/logging.logWriter" = [
      "serviceAccount:${google_service_account.cloudbuild_sa.account_id}@example-prod-devops.iam.gserviceaccount.com",
    ],
  }
}

resource "google_service_account" "cloudbuild_sa" {
  account_id   = "cloudbuild-sa"
  display_name = "Cloudbuild Service Account"

  description = "Cloudbuild Service Account"

  project = module.project.project_id
}

module "example_logs_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "example-logs-bucket"
  project_id = module.project.project_id
  location   = "us-central1"

  labels = {
    env = "prod"
  }
}
