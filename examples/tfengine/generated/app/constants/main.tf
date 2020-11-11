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

# The constants module contains shared values across multiple Terraform deployments.
output "values" {
  value = {
    dev = {
      env_code  = "d"
      folder_id = "456"
    }
    shared = {
      bigquery_location   = "us-east1"
      billing_account     = "000"
      cloud_sql_region    = "us-central1"
      cloud_sql_zone      = "a"
      compute_region      = "us-central1"
      env_code            = "s"
      folder_id           = "123"
      gke_region          = "us-central1"
      healthcare_location = "us-central1"
      project_prefix      = "example-prefix"
      secret_locations    = ["us-central1"]
      state_bucket        = "example-state"
      storage_location    = "us-central1"
    }
  }
}
