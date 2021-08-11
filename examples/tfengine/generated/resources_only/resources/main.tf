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
    prefix = "resources"
  }
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.1.0"

  project_id      = var.exists ? var.project_id : ""
  name            = var.project_id
  org_id          = var.parent_type == "organization" ? var.parent_id : ""
  folder_id       = var.parent_type == "folder" ? var.parent_id : ""
  billing_account = var.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  enable_shared_vpc_host_project = var.is_shared_vpc_host

  svpc_host_project_id = var.shared_vpc_attachment.host_project_id
  shared_vpc_subnets   = var.shared_vpc_attachment.subnets
  activate_apis        = var.apis

  activate_api_identities = var.exists ? [] : var.api_identities
}

module "one_billion_ms_example_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.5.0"

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
  version = "~> 2.1.0"

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

  name       = "example-prod-bucket"
  project_id = module.project.project_id
  location   = "us-central1"

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
