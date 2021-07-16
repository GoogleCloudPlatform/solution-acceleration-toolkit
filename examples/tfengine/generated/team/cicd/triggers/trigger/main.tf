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

resource "google_cloudbuild_trigger" "on_push" {
  count       = var.skip ? 0 : 1
  disabled    = var.run_on_push
  provider    = google-beta
  project     = var.project_id
  name        = "tf-${var.trigger_type}-${var.name}"
  description = "Terraform ${var.trigger_type} job triggered on push event."

  included_files = [
    "${var.terraform_root_prefix}**",
  ]

  github {
    owner = var.github.owner
    name  = var.github.name
    pull_request {
      branch = "^${var.branch_name}$"
    }
  }

  filename = "${var.terraform_root_prefix}cicd/configs/${var.filename}"

  substitutions = {
    _TERRAFORM_ROOT = var.terraform_root
    _MANAGED_DIRS   = var.managed_dirs
  }

  depends_on = [
    google_project_service.services,
  ]
}

# Create another trigger as Pull Request Cloud Build triggers cannot be used by Cloud Scheduler.
resource "google_cloudbuild_trigger" "scheduled" {
  count = (!var.skip && var.run_on_schedule != "") ? 1 : 0
  # Always disabled on push to branch.
  disabled    = true
  provider    = google-beta
  project     = var.project_id
  name        = "tf-${var.trigger_type}-scheduled-${var.name}"
  description = "Terraform ${var.trigger_type} job triggered on schedule."

  included_files = [
    "${var.terraform_root_prefix}**",
  ]

  github {
    owner = var.github.owner
    name  = var.github.name
    push {
      branch = "^${var.branch_name}$"
    }
  }

  filename = "${var.terraform_root_prefix}cicd/configs/${var.filename}"

  substitutions = {
    _TERRAFORM_ROOT = var.terraform_root
    _MANAGED_DIRS   = var.managed_dirs
  }

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_cloud_scheduler_job" "scheduler_job" {
  count            = (!var.skip && var.run_on_schedule != "") ? 1 : 0
  project          = var.project_id
  name             = "${var.trigger_type}-scheduler-${var.name}"
  region           = var.scheduler_region
  schedule         = var.run_on_schedule
  time_zone        = "America/New_York" # Eastern Standard Time (EST)
  attempt_deadline = "60s"
  http_target {
    http_method = "POST"
    oauth_token {
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = google_service_account.cloudbuild_scheduler_sa.email
    }
    uri  = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.scheduled}:run"
    body = base64encode("{\"branchName\":\"${var.branch_name}\"}")
  }
  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
  ]
}
