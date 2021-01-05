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
    prefix = "example-prod-data"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 10.0.1"

  name                    = "example-prod-data"
  org_id                  = ""
  folder_id               = "12345678"
  billing_account         = "000-000-000"
  lien                    = true
  default_service_account = "keep"

  shared_vpc = "example-prod-networks"
  activate_apis = [
    "bigquery.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
  ]
  activate_api_identities = [
    {
      api = "healthcare.googleapis.com"

      roles = [
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
      ]
    },
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
      group_by_email = "example-data-viewers@example.com"
      role           = "roles/bigquery.dataViewer"
    },
  ]
  dataset_labels = {
    env  = "prod"
    type = "phi"
  }
}

module "example_mysql_instance" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 4.4.0"

  name              = "example-mysql-instance"
  project_id        = module.project.project_id
  region            = "us-central1"
  zone              = "a"
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "projects/example-prod-networks/global/networks/example-network"
  user_labels = {
    env  = "prod"
    type = "no-phi"
  }
}

module "example_healthcare_dataset" {
  source  = "terraform-google-modules/healthcare/google"
  version = "~> 1.2.0"

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
      notification_config = {
        pubsub_topic = "projects/example-prod-data/topics/example-topic"
      }
      labels = {
        env  = "prod"
        type = "phi"
      }
    },
  ]
  fhir_stores = [
    {
      name    = "example-fhir-store-a"
      version = "R4"

      enable_update_create          = true
      disable_referential_integrity = false
      disable_resource_versioning   = false
      enable_history_import         = false
      iam_members = [
        {
          member = "group:example-fhir-viewers@example.com"
          role   = "roles/healthcare.fhirStoreViewer"
        },
      ]
      notification_config = {
        pubsub_topic = "projects/example-prod-data/topics/example-topic"
      }
      stream_configs = [
        {
          bigquery_destination = {
            dataset_uri = "bq://example-prod-data.example_dataset_id"
            schema_config = {
              recursive_structure_depth = 3

              schema_type = "ANALYTICS"
            }
          }
          resource_types = ["Patient"]
        },
      ]
      labels = {
        env  = "prod"
        type = "phi"
      }
    },
    {
      name    = "example-fhir-store-b"
      version = "R4"

      labels = {
        env  = "prod"
        type = "phi"
      }
    },
  ]
  hl7_v2_stores = [
    {
      name = "example-hl7-store"
      notification_configs = [
        {
          pubsub_topic = "projects/example-prod-data/topics/example-topic"
        },
      ]
      parser_config = {
        version = "V2"
        schema  = <<EOF
{
  "schematizedParsingType": "SOFT_FAIL",
  "ignoreMinOccurs": true
}
EOF
      }
      labels = {
        env  = "prod"
        type = "phi"
      }
    },
  ]
}

module "project_iam_members" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 6.4.0"

  projects = [module.project.project_id]
  mode     = "additive"

  bindings = {
    "roles/cloudsql.client" = [
      "serviceAccount:bastion@example-prod-networks.iam.gserviceaccount.com",
    ],
  }
}



module "example_prod_bucket" {
  source     = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version    = "~> 1.4"
  name       = "example-prod-bucket"
  project_id = module.project.project_id
  location   = "us-central1"

  labels = {
    env  = "prod"
    type = "phi"
  }
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
      member = "group:example-data-viewers@example.com"
      role   = "roles/storage.objectViewer"
    },
  ]
}
