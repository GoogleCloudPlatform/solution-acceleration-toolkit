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
  }
}

resource "random_password" "db" {
  length  = 16
  special = true
}




resource "google_secret_manager_secret" "manual_sql_db_user" {
  provider = google-beta

  secret_id = "manual-sql-db-user"
  project   = var.project_id

  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret" "auto_sql_db_password" {
  provider = google-beta

  secret_id = "auto-sql-db-password"
  project   = var.project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "auto_sql_db_password_data" {
  provider = google-beta

  secret      = google_secret_manager_secret.auto_sql_db_password.id
  secret_data = "${random_password.db.result}"
}
