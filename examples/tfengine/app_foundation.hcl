# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: This example is still under development and is not considered stable!
# Breaking changes to components for this example will not be part of releases.

template "app" {
  recipe_path = "../../templates/tfengine/recipes/app_foundation.hcl"
  data = {
    constants = {
      shared = {
        env_code            = "s"
        folder_id           = "123"
        billing_account     = "000"
        project_prefix      = "example-prefix"
        state_bucket        = "example-state"
        bigquery_location   = "us-east1" # No BigQuery region in us-central1.
        cloud_sql_region    = "us-central1"
        cloud_sql_zone      = "a"
        compute_region      = "us-central1"
        gke_region          = "us-central1"
        storage_location    = "us-central1"
        secret_locations    = ["us-central1"]
        healthcare_location = "us-central1"
      }
      dev = {
        env_code  = "d"
        folder_id = "456"
      }
      prod = {
        env_code  = "p"
        folder_id = "789"
      }
    }
    devops = {
      admins_group       = "admins@example.com"
      devops_owners      = ["group:devops-owners-group@example.com"]
      enable_gcs_backend = false # TODO(user): change to true after initial devops deployment.
    }

    res = {
      gke_clusters = [{
        name                        = "example-gke"
        master_ipv4_cidr_block      = "192.168.0.0/28"
        subnet_ip_range             = "10.2.0.0/16"
        pods_secondary_ip_range     = "172.16.0.0/14"
        services_secondary_ip_range = "172.20.0.0/14"
      }]
    }
  }
}
