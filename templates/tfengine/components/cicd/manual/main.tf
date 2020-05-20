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

# This folder contains Terraform resources to setup CI/CD, which includes:
# - Necessary APIs to enable in the devops project for CI/CD purposes,
# - Necessary IAM permissions to set to enable Cloud Build Service Account perform CI/CD jobs.
# - Cloud Build Triggers to monitor GitHub repos to start CI/CD jobs.
#
# The Cloud Build configs can be found under the configs/ sub-folder.

# ***NOTE***: First follow
# https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app
# to install the Cloud Build app and connect your GitHub repository to your Cloud project.

terraform {
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "{{.state_bucket}}"
    prefix = "cicd/manual"
  }
}

data "google_project" "devops" {
  project_id = var.project_id
}

locals {
  services = [
    "admin.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
  ]
  cloudbuild_sa_viewer_roles = [
    "roles/browser",
    "roles/iam.securityReviewer",
  ]
  cloudbuild_sa_editor_roles = [
    "roles/compute.xpnAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/resourcemanager.folderCreator",
    "roles/resourcemanager.projectCreator",
  ]
  cloudbuild_devops_roles = [
    # Enable Cloud Build SA to list and enable APIs in the devops project.
    "roles/serviceusage.serviceUsageAdmin",
  ]
}

locals {
  # Covert "" and "/" to "." in case users use them to indicate root of the git repo.
  terraform_root = trim((var.terraform_root == "" || var.terraform_root == "/") ? "." : var.terraform_root, "/")
  # ./ to indicate root is not recognized by Cloud Build Trigger.
  terraform_root_prefix = local.terraform_root == "." ? "" : "${local.terraform_root}/"
  cloud_build_sa        = "serviceAccount:${data.google_project.devops.number}@cloudbuild.gserviceaccount.com"
}

# Cloud Build - API
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# IAM permissions to allow Cloud Build Service Account use the billing account.
resource "google_billing_account_iam_member" "binding" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = local.cloud_build_sa
  depends_on = [
    google_project_service.services,
  ]
}

# IAM permissions to allow approvers and contributors to view the build results.
resource "google_project_iam_member" "cloudbuild_viewers" {
  for_each = toset(var.build_viewers)
  project  = var.project_id
  role     = "roles/cloudbuild.builds.viewer"
  member   = each.value
  depends_on = [
    google_project_service.services,
  ]
}

# Cloud Build - Cloud Build Service Account IAM permissions
# IAM permissions to allow Cloud Build SA to access state.
resource "google_storage_bucket_iam_member" "cloudbuild_state_iam" {
  bucket = var.state_bucket
  role   = var.continuous_deployment_enabled ? "roles/storage.admin" : "roles/storage.objectViewer"
  member = local.cloud_build_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the organization.
resource "google_organization_iam_member" "cloudbuild_sa_org_iam" {
  for_each = toset(var.continuous_deployment_enabled ? local.cloudbuild_sa_editor_roles : local.cloudbuild_sa_viewer_roles)
  org_id   = var.org_id
  role     = each.value
  member   = local.cloud_build_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the devops project.
resource "google_project_iam_member" "cloudbuild_sa_project_iam" {
  for_each = toset(local.cloudbuild_devops_roles)
  project  = var.project_id
  role     = each.key
  member   = local.cloud_build_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Cloud Build Triggers for CI.
resource "google_cloudbuild_trigger" "validate" {
  disabled = ! var.trigger_enabled
  provider = google-beta
  project  = var.project_id
  name     = "tf-validate"

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  github {
    owner = var.repo_owner
    name  = var.repo_name
    pull_request {
      branch = var.branch_regex
    }
  }

  filename = "${local.terraform_root_prefix}cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
  }

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_cloudbuild_trigger" "plan" {
  disabled = ! var.trigger_enabled
  provider = google-beta
  project  = var.project_id
  name     = "tf-plan"

  included_files = [
    "${local.terraform_root_prefix}live/**",
    "${local.terraform_root_prefix}cicd/configs/**"
  ]

  github {
    owner = var.repo_owner
    name  = var.repo_name
    pull_request {
      branch = var.branch_regex
    }
  }

  filename = "${local.terraform_root_prefix}cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
  }

  depends_on = [
    google_project_service.services,
  ]
}

# Cloud Build Triggers for CD.
resource "google_cloudbuild_trigger" "apply" {
  count    = var.continuous_deployment_enabled ? 1 : 0
  disabled = ! var.trigger_enabled
  provider = google-beta
  project  = var.project_id
  name     = "tf-apply"

  included_files = [
    "${local.terraform_root_prefix}live/**",
    "${local.terraform_root_prefix}cicd/configs/**"
  ]

  github {
    owner = var.repo_owner
    name  = var.repo_name
    push {
      branch = var.branch_regex
    }
  }

  filename = "${local.terraform_root_prefix}cicd/configs/tf-apply.yaml"

  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
  }

  depends_on = [
    google_project_service.services,
  ]
}
