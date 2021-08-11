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
    google      = ">=3.0, <= 3.71"
    google-beta = "~>3.50"
    null        = "~> 3.0"
    kubernetes  = "~> 1.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "project_secrets"
  }
}

resource "random_password" "db" {
  length  = 16
  special = true
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control

module "project" {
  source  = "terraform-google-modules/zaproject-factory/google"
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

resource "google_secret_manager_secret" "auto_sql_db_password" {
  provider = google-beta

  secret_id = "auto-sql-db-password"
  project   = module.project.project_id

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "auto_sql_db_password_data" {
  provider = google-beta

  secret      = google_secret_manager_secret.auto_sql_db_password.id
  secret_data = random_password.db.result
}
