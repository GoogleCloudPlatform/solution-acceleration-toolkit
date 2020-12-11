{{- /* Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

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
  required_version = ">=0.13, <0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "{{.constants.shared.state_bucket}}"
    prefix = "cicd"
  }
}

locals {
  cloudbuild_sa_editor_roles = [
    "roles/compute.xpnAdmin",
    "roles/logging.configWriter",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.folderAdmin",
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
  cloudbuild_sa        = "serviceAccount:${data.google_project.devops.number}@cloudbuild.gserviceaccount.com"
}

module "constants" {
  source = "../../../modules/constants"
}

locals {
  constants = module.constants.values.shared
}

data "google_project" "devops" {
  project_id = "${local.constants.project_prefix}-${local.constants.env_code}-devops"
}

# IAM permissions to allow approvers and contributors to view the cloud build jobs.
resource "google_project_iam_member" "cloudbuild_builds_viewers" {
  for_each = toset(var.build_viewers)
  project  = data.google_project.devops.project_id
  role     = "roles/cloudbuild.builds.viewer"
  member   = each.value
}

# IAM permissions to allow approvers and contributors to view the cloud build logs.
# https://cloud.google.com/cloud-build/docs/securing-builds/store-view-build-logs
resource "google_project_iam_member" "cloudbuild_logs_viewers" {
  for_each = toset(var.build_viewers)
  project  = data.google_project.devops.project_id
  role     = "roles/viewer"
  member   = each.value
}

# IAM permissions to allow Cloud Build Service Account use the billing account.
resource "google_billing_account_iam_member" "binding" {
  billing_account_id = local.constants.billing_account
  role               = "roles/billing.user"
  member             = local.cloudbuild_sa
}

# Cloud Build - Cloud Build Service Account IAM permissions
# IAM permissions to allow Cloud Build SA to access state.
resource "google_storage_bucket_iam_member" "cloudbuild_state_iam" {
  bucket = local.constants.state_bucket
  role   = "roles/storage.admin"
  member = local.cloudbuild_sa
}

locals {
  folder_ids = [for env in module.constants.values: env.folder_id]
  folder_roles = flatten([
    for f in local.folder_ids : [
      for r in local.cloudbuild_sa_editor_roles : {
        folder = f
        role   = r
      }
    ]
  ])
}

# Grant Cloud Build Service Account access to the folder.
resource "google_folder_iam_member" "cloudbuild_sa_folder_iam" {
  for_each = { for fr in local.folder_roles : "${fr.folder} ${fr.role}" => fr }
  folder   = each.value.folder
  role     = each.value.role
  member   = local.cloudbuild_sa
}

resource "google_sourcerepo_repository" "configs" {
  project  = data.google_project.devops.project_id
  name     = var.source_repo_name
}

# Grant Cloud Build Service Account access to the devops project.
resource "google_project_iam_member" "cloudbuild_sa_project_iam" {
  for_each = toset(local.cloudbuild_devops_roles)
  project  = data.google_project.devops.project_id
  role     = each.key
  member   = local.cloudbuild_sa
}

resource "google_cloudbuild_trigger" "validate" {
  provider    = google-beta
  project     = data.google_project.devops.project_id
  name        = "tf-validate"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]
  trigger_template {
    repo_name   = google_sourcerepo_repository.configs.name
    branch_name = var.branch_name
  }
  filename = "${local.terraform_root_prefix}cicd/configs/tf-validate.yaml"
  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
  }
}

resource "google_cloudbuild_trigger" "plan" {
  provider    = google-beta
  project     = data.google_project.devops.project_id
  name        = "tf-plan"
  description = "Terraform plan job triggered on push event."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]
  trigger_template {
    repo_name   = google_sourcerepo_repository.configs.name
    branch_name = var.branch_name
  }
  filename = "${local.terraform_root_prefix}cicd/configs/tf-plan.yaml"
  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
  }
}

resource "google_cloudbuild_trigger" "apply" {
  provider    = google-beta
  project     = data.google_project.devops.project_id
  name        = "tf-apply"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "${local.terraform_root_prefix}**",
  ]
  trigger_template {
    repo_name   = google_sourcerepo_repository.configs.name
    branch_name = var.branch_name
  }
  filename = "${local.terraform_root_prefix}cicd/configs/tf-apply.yaml"
  substitutions = {
    _TERRAFORM_ROOT = local.terraform_root
  }
}
