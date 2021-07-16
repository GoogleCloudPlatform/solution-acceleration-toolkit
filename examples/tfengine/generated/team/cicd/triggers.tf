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

# ================== Triggers for "prod" environment ==================

resource "google_cloudbuild_trigger" "validate_prod" {
  provider    = google-beta
  project     = var.project_id
  name        = "tf-validate-prod"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    pull_request {
      branch = "^main$"
    }
  }

  filename = "terraform/cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "project_secrets project_networks project_apps project_data additional_iam_members"
  }

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_cloudbuild_trigger" "plan_prod" {
  provider    = google-beta
  project     = var.project_id
  name        = "tf-plan-prod"
  description = "Terraform plan job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    pull_request {
      branch = "^main$"
    }
  }

  filename = "terraform/cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "project_secrets project_networks project_apps project_data additional_iam_members"
  }

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_cloudbuild_trigger" "apply_prod" {
  disabled    = true
  provider    = google-beta
  project     = var.project_id
  name        = "tf-apply-prod"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "terraform/**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    push {
      branch = "^main$"
    }
  }

  filename = "terraform/cicd/configs/tf-apply.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "project_secrets project_networks project_apps project_data additional_iam_members"
  }

  depends_on = [
    google_project_service.services,
  ]
}


