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
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "project_data"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  # TODO(xingao): pin to released version once available.
  source = "github.com/terraform-google-modules/terraform-google-project-factory?ref=c41ba360a6bc6800a30d284b8fa23eb3ef5a8d7f"
  # source  = "terraform-google-modules/project-factory/google"
  # version = "~> 10.1.0"

  name            = "example-prod-data"
  org_id          = ""
  folder_id       = "12345678"
  billing_account = "000-000-000"
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  svpc_host_project_id = "example-prod-networks"
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
  dataset_labels = {
    env  = "prod"
    type = "phi"
  }
}

module "sql_instance" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 4.4.0"

  name              = "sql-instance"
  project_id        = module.project.project_id
  region            = "us-central1"
  zone              = "a"
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "projects/example-prod-networks/global/networks/example-network"
  user_name         = "admin"
  user_password     = data.google_secret_manager_secret_version.db_password.secret_data
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
      "serviceAccount:bastion@example-networks.iam.gserviceaccount.com",
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
