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

module "constants" {
  source = "../constants"
}

locals {
  constants = merge(module.constants.values.shared, module.constants.values[var.env])
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1.0"

  name            = "${local.constants.project_prefix}-${local.constants.env_code}-data"
  org_id          = ""
  folder_id       = local.constants.folder_id
  billing_account = local.constants.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  svpc_host_project_id = "${local.constants.project_prefix}-${local.constants.env_code}-networks"
  activate_apis        = []
}

module "one_billion_ms_example_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.4.0"

  dataset_id                  = "1billion_ms_example_dataset"
  project_id                  = module.project.project_id
  location                    = local.constants.bigquery_location
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
    type = "phi"
  }
}

module "example_mysql_instance" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 4.4.0"

  name              = "example-mysql-instance"
  project_id        = module.project.project_id
  region            = local.constants.cloud_sql_region
  zone              = local.constants.cloud_sql_zone
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "projects/example-prod-networks/global/networks/example-network"
  user_labels = {
    type = "no-phi"
  }
}

module "example_healthcare_dataset" {
  source  = "terraform-google-modules/healthcare/google"
  version = "~> 1.2.1"

  name     = "example-healthcare-dataset"
  project  = module.project.project_id
  location = local.constants.healthcare_location

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
        type = "phi"
      }
    },
  ]
  hl7_v2_stores = [
    {
      name = "example-hl7-store"
      labels = {
        type = "phi"
      }
    },
  ]
  depends_on = [
    module.project
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
  name       = "${local.constants.project_prefix}-${local.constants.env_code}-example-prod-bucket"
  project_id = module.project.project_id
  location   = local.constants.storage_location

  labels = {
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
