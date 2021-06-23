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
    _MANAGED_DIRS   = "groups audit example-prod-networks monitor folders"
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
    _MANAGED_DIRS   = "groups audit example-prod-networks monitor folders"
  }

  depends_on = [
    google_project_service.services,
  ]
}

# Create another trigger as Pull Request Cloud Build triggers cannot be used by Cloud Scheduler.
resource "google_cloudbuild_trigger" "plan_scheduled_prod" {
  # Always disabled on push to branch.
  disabled    = true
  provider    = google-beta
  project     = var.project_id
  name        = "tf-plan-scheduled-prod"
  description = "Terraform plan job triggered on schedule."

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

  filename = "terraform/cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "groups audit example-prod-networks monitor folders"
  }

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_cloud_scheduler_job" "plan_scheduler_prod" {
  project          = var.project_id
  name             = "plan-scheduler-prod"
  region           = "us-east1"
  schedule         = "0 12 * * *"
  time_zone        = "America/New_York" # Eastern Standard Time (EST)
  attempt_deadline = "60s"
  http_target {
    http_method = "POST"
    oauth_token {
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = google_service_account.cloudbuild_scheduler_sa.email
    }
    uri  = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.plan_scheduled_prod.id}:run"
    body = base64encode("{\"branchName\":\"main\"}")
  }
  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
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
    _MANAGED_DIRS   = "groups audit example-prod-networks monitor folders"
  }

  depends_on = [
    google_project_service.services,
  ]
}


