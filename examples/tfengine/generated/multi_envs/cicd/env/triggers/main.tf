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

locals {
  terraform_root        = var.terraform_root == "/" ? "." : var.terraform_root
  terraform_root_prefix = local.terraform_root == "." ? "" : "${local.terraform_root}/"
}

resource "google_cloudbuild_trigger" "push" {
  count       = var.push.skip ? 0 : 1
  disabled    = var.push.disabled
  provider    = google-beta
  project     = var.project_id
  name        = "tf-${var.command}-${var.env}"
  description = "Terraform ${var.command} job triggered on push event."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  trigger_template {
    repo_name   = var.cloud_source_repository.name
    branch_name = "^${var.branch_name}$"
  }

  filename = "${local.terraform_root_prefix}cicd/configs/tf-${var.command}.yaml"

  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
    _MANAGED_DIRS   = var.managed_dirs
  }
}

# Create another trigger as Pull Request Cloud Build triggers cannot be used by Cloud Scheduler.
resource "google_cloudbuild_trigger" "scheduled" {
  count       = var.scheduled.skip ? 0 : 1
  disabled    = var.scheduled.disabled
  provider    = google-beta
  project     = var.project_id
  name        = "tf-${var.command}-scheduled-${var.env}"
  description = "Terraform ${var.command} job triggered on schedule."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  trigger_template {
    repo_name   = var.cloud_source_repository.name
    branch_name = "^${var.branch_name}$"
  }

  filename = "${local.terraform_root_prefix}cicd/configs/tf-${var.command}.yaml"

  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
    _MANAGED_DIRS   = var.managed_dirs
  }
}

resource "google_cloud_scheduler_job" "scheduler" {
  # Count meta-argument logic is duplicated with the skip logic of the env/main.tf module
  # for `validate` and `plan`.
  # This is intentionally done while for the `apply` command, it's needed to not create the scheduler
  # when the `scheduled` job is only used as a `push`.
  #
  # The duplication might be removed once #1014 is solved. 
  # Also more context on why this is happening is documented there.
  count            = (var.scheduled.skip || var.run_on_schedule == "") ? 0 : 1
  project          = var.project_id
  name             = "${var.command}-scheduler-${var.env}"
  region           = var.scheduler_region
  schedule         = var.run_on_schedule
  time_zone        = "America/New_York" # Eastern Standard Time (EST)
  attempt_deadline = "60s"
  http_target {
    http_method = "POST"
    oauth_token {
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = var.service_account_email
    }
    uri  = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.scheduled[0].id}:run"
    body = base64encode("{\"branchName\":\"${var.branch_name}\"}")
  }
}
