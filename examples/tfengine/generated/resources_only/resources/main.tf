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
    prefix = "resources"
  }
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.4.0"

  project_id    = "example-prod-project"
  activate_apis = []
}

module "one_billion_ms_example_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 7.0.0"

  dataset_id                  = "1billion_ms_example_dataset"
  project_id                  = module.project.project_id
  location                    = "us-east1"
  default_table_expiration_ms = 1e+09
  access = [
    {
      role          = "roles/bigquery.dataOwner"
      special_group = "projectOwners"
    },
    {
      group_by_email = "example-data-viewers@example.com"
      role           = "roles/bigquery.dataViewer"
    },
  ]
  dataset_labels = {
    env  = "prod"
    type = "phi"
  }
}

module "example_healthcare_dataset" {
  source  = "terraform-google-modules/healthcare/google"
  version = "~> 2.4.0"

  name     = "example-healthcare-dataset"
  project  = module.project.project_id
  location = "us-central1"

  iam_members = [
    {
      member = "group:example-healthcare-dataset-viewers@example.com"
      role   = "roles/healthcare.datasetViewer"
    },
  ]
  dicom_stores = [
    {
      name = "example-dicom-store"
      labels = {
        env  = "prod"
        type = "phi"
      }
    },
  ]
  fhir_stores = [
    {
      name    = "example-fhir-store"
      version = "R4"

      iam_members = [
        {
          member = "group:example-fhir-viewers@example.com"
          role   = "roles/healthcare.fhirStoreViewer"
        },
      ]
      labels = {
        env  = "prod"
        type = "phi"
      }
    },
  ]
  hl7_v2_stores = [
    {
      name = "example-hl7-store"
      labels = {
        env  = "prod"
        type = "phi"
      }
    },
  ]
  depends_on = [
    module.project
  ]
}

resource "google_service_account" "example_sa" {
  account_id   = "example-sa"
  display_name = "Example Service Account"

  description = "Example Service Account"

  project = module.project.project_id
}

module "example_prod_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name          = "example-prod-bucket"
  project_id    = module.project.project_id
  location      = "us-central1"
  force_destroy = false

  labels = {
    env  = "prod"
    type = "phi"
  }
  iam_members = [
    {
      member = "group:example-data-viewers@example.com"
      role   = "roles/storage.objectViewer"
    },
  ]
}
