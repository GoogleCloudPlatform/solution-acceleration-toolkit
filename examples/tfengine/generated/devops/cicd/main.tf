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
    bucket = "example-terraform-state"
    prefix = "cicd"
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
    "compute.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "appengine.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]
  cloudbuild_sa_viewer_roles = [
    "roles/browser",
    "roles/iam.securityReviewer",
    "roles/secretmanager.secretViewer",
    "roles/secretmanager.secretAccessor",
  ]
  cloudbuild_sa_editor_roles = [
    "roles/compute.xpnAdmin",
    "roles/logging.configWriter",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.organizationAdmin",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderCreator",
  ]
  cloudbuild_devops_roles = [
    # Allow CICD to view all resources within the devops project so it can run terraform plans against them.
    # It won't be able to actually apply any changes unless granted the permission in this list.
    "roles/viewer",

    # Enable Cloud Build SA to list and enable APIs in the devops project.
    "roles/serviceusage.serviceUsageAdmin",
  ]
}

locals {
  # Covert "" and "/" to "." in case users use them to indicate root of the git repo.
  terraform_root = trim((var.terraform_root == "" || var.terraform_root == "/") ? "." : var.terraform_root, "/")
  # ./ to indicate root is not recognized by Cloud Build Trigger.
  terraform_root_prefix = local.terraform_root == "." ? "" : "${local.terraform_root}/"
  cloudbuild_sa         = "serviceAccount:${data.google_project.devops.number}@cloudbuild.gserviceaccount.com"
}

# Cloud Build - API
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# IAM permissions to allow approvers and contributors to view the cloud build jobs.
resource "google_project_iam_member" "cloudbuild_builds_viewers" {
  for_each = toset(var.build_viewers)
  project  = var.project_id
  role     = "roles/cloudbuild.builds.viewer"
  member   = each.value
  depends_on = [
    google_project_service.services,
  ]
}

# IAM permissions to allow approvers and contributors to view the cloud build logs.
# https://cloud.google.com/cloud-build/docs/securing-builds/store-view-build-logs
resource "google_project_iam_member" "cloudbuild_logs_viewers" {
  for_each = toset(var.build_viewers)
  project  = var.project_id
  role     = "roles/viewer"
  member   = each.value
  depends_on = [
    google_project_service.services,
  ]
}

# IAM permissions to allow Cloud Build Service Account use the billing account.
resource "google_billing_account_iam_member" "binding" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Cloud Build - Cloud Build Service Account IAM permissions
# IAM permissions to allow Cloud Build SA to access state.
resource "google_storage_bucket_iam_member" "cloudbuild_state_iam" {
  bucket = var.state_bucket
  role   = "roles/storage.admin"
  member = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the organization.
resource "google_organization_iam_member" "cloudbuild_sa_organization_iam" {
  for_each = toset(local.cloudbuild_sa_editor_roles)
  org_id   = 12345678
  role     = each.value
  member   = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the devops project.
resource "google_project_iam_member" "cloudbuild_sa_project_iam" {
  for_each = toset(local.cloudbuild_devops_roles)
  project  = var.project_id
  role     = each.key
  member   = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}


# Cloud Scheduler requires an App Engine app created in the project.
resource "google_app_engine_application" "cloudbuild_scheduler_app" {
  project     = var.project_id
  location_id = "us-east1"
  depends_on = [
    google_project_service.services,
  ]
}

# Service Account and its IAM permissions used for Cloud Scheduler to schedule Cloud Build triggers.
resource "google_service_account" "cloudbuild_scheduler_sa" {
  project      = var.project_id
  account_id   = "cloudbuild-scheduler-sa"
  display_name = "Cloud Build scheduler service account"
  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_member" "cloudbuild_scheduler_sa_project_iam" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.cloudbuild_scheduler_sa.email}"
  depends_on = [
    google_project_service.services,
  ]
}

resource "google_cloudbuild_trigger" "validate" {
  provider    = google-beta
  project     = var.project_id
  name        = "tf-validate"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    pull_request {
      branch = "^master$"
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
  provider    = google-beta
  project     = var.project_id
  name        = "tf-plan"
  description = "Terraform plan job triggered on push event."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    pull_request {
      branch = "^master$"
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
# Create another trigger as Pull Request Cloud Build triggers cannot be used by Cloud Scheduler.
resource "google_cloudbuild_trigger" "plan_scheduled" {
  # Always disabled on push to branch.
  disabled    = true
  provider    = google-beta
  project     = var.project_id
  name        = "tf-plan-scheduled"
  description = "Terraform plan job triggered on schedule."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    push {
      branch = "^master$"
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

resource "google_cloud_scheduler_job" "plan_scheduler" {
  project          = var.project_id
  name             = "plan-scheduler"
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
    uri  = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.plan_scheduled.id}:run"
    body = base64encode("{\"branchName\":\"master\"}")
  }
  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
  ]
}

resource "google_cloudbuild_trigger" "apply" {
  disabled    = true
  provider    = google-beta
  project     = var.project_id
  name        = "tf-apply"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]

  github {
    owner = "GoogleCloudPlatform"
    name  = "example"
    push {
      branch = "^master$"
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
