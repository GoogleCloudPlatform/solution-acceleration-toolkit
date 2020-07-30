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
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "example-prod-data"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 8.1.0"

  name                    = "example-prod-data"
  org_id                  = ""
  folder_id               = "12345678"
  billing_account         = "000-000-000"
  lien                    = true
  default_service_account = "keep"
  skip_gcloud_download    = true
  shared_vpc              = "example-prod-networks"
  activate_apis = [
    "bigquery.googleapis.com",
    "compute.googleapis.com",
    "healthcare.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]
}


module "one_billion_ms_example_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.3.0"

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
      group_by_email = "example-readers@example.com"
      role           = "roles/bigquery.dataViewer"
    },
  ]

}


module "example_mysql_instance" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 3.2.0"

  name              = "example-mysql-instance"
  project_id        = module.project.project_id
  region            = "us-central1"
  zone              = "a"
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "projects/example-prod-networks/global/networks/example-network"


}

module "example_healthcare_dataset" {
  source  = "terraform-google-modules/healthcare/google"
  version = "~> 1.0.0"

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

    }
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
    }
  ]

  hl7_v2_stores = [
    {
      name = "example-hl7-store"

    }
  ]
}
module "project_iam_members" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 6.1.0"

  projects = [module.project.project_id]
  mode     = "additive"

  bindings = {
    "roles/cloudsql.client" = [
      "serviceAccount:bastion@example-prod-networks.iam.gserviceaccount.com",
    ],
  }
}

module "example_prod_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "example-prod-bucket"
  project_id = module.project.project_id
  location   = "us-central1"

  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age        = 7
        with_state = "ANY"
      }
    }
  ]
  iam_members = [
    {
      member = "group:example-readers@example.com"
      role   = "roles/storage.objectViewer"
    },
  ]
}
