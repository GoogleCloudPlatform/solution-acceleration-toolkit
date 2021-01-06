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

resource "random_password" "db" {
  length  = 16
  special = true
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.0.2"

  name            = "${local.constants.project_prefix}-${local.constants.env_code}-secrets"
  org_id          = ""
  folder_id       = local.constants.folder_id
  billing_account = local.constants.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  create_project_sa       = false
  activate_apis           = ["secretmanager.googleapis.com"]
}

resource "google_secret_manager_secret" "manual_sql_db_user" {
  provider = google-beta

  secret_id = "manual-sql-db-user"
  project   = module.project.project_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = toset(local.constants.secret_locations)
        content {
          location = replicas.value
        }
      }
    }
  }
}


resource "google_secret_manager_secret" "auto_sql_db_password" {
  provider = google-beta

  secret_id = "auto-sql-db-password"
  project   = module.project.project_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = toset(local.constants.secret_locations)
        content {
          location = replicas.value
        }
      }
    }
  }
}

resource "google_secret_manager_secret_version" "auto_sql_db_password_data" {
  provider = google-beta

  secret      = google_secret_manager_secret.auto_sql_db_password.id
  secret_data = random_password.db.result
}
