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

resource "google_cloudbuild_trigger" "trigger" {
  count       = var.skip ? 0 : 1
  disabled    = !var.run_on_push
  provider    = google-beta
  project     = var.project_id
  name        = var.name
  description = var.description

  included_files = [
    "${var.terraform_root_prefix}**",
  ]

  dynamic "trigger_template" {
    for_each = var.cloud_source_repository
    content {
      repo_name   = trigger_template.value["name"]
      branch_name = "^${pull_request.value["branch_name"]}$"
    }
  }

  filename = "${var.terraform_root_prefix}cicd/configs/${var.filename}"

  substitutions = {
    _TERRAFORM_ROOT = var.terraform_root
    _MANAGED_DIRS   = var.managed_dirs
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}
