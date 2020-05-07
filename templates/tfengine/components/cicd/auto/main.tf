# Copyright 2020 Google Inc.
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

# This folder contains additional Terraform resources in the devops project to configure CI/CD which
# are also managed by CI/CD.
#
# Note that, the resources to put here should be carefully reviewed and picked as devops project
# is sensitive and most changes should done by a human operator to avoid CI/CD misconfigures itself.

terraform {
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "{{.STATE_BUCKET}}"
    prefix = "cicd/auto"
  }
}

# Additional APIs to enable in the devops project so Cloud Build Service Account can manage those
# resources in other projects.
#
# For a Service Account to manage GCP resources, some resources require the same API to be enabled
# in the GCP project that hosts the Service Account as well.
resource "google_project_service" "managed_services" {
  for_each           = toset(var.managed_services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
