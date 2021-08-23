{{- /* Copyright 2021 Google LLC

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
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "{{.state_bucket}}"
    prefix = "cicd"
  }
}

data "google_project" "devops" {
  project_id = var.project_id
}

locals {
  // Github and CSR are mutually exclusive so there shouldn't be both specified on the same
  // terraform configuration, but in case they're, priority goes to github since it creates the
  // less amount of extra resources 
  is_github = var.github.name != ""
  is_cloud_source_repository = !local.is_github && var.cloud_source_repository.name != ""
  
  cloudbuild_sa = "serviceAccount:${data.google_project.devops.number}@cloudbuild.gserviceaccount.com"
  has_scheduled_jobs = anytrue([for env in var.envs : env.triggers.validate.run_on_schedule || env.triggers.plan.run_on_schedule || env.triggers.apply.run_on_schedule])
  has_apply_jobs = anytrue([for env in var.envs : !env.triggers.apply.skip])
  services = concat(
    [
      "admin.googleapis.com",
      "bigquery.googleapis.com",
      "cloudbilling.googleapis.com",
      "cloudbuild.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "compute.googleapis.com",
      "iam.googleapis.com",
      "servicenetworking.googleapis.com",
      "serviceusage.googleapis.com",
      "sqladmin.googleapis.com"
    ],
    local.is_cloud_source_repository ? [
      "sourcerepo.googleapis.com",
    ] : [],
    local.has_scheduled_jobs ? [
      "appengine.googleapis.com",
      "cloudscheduler.googleapis.com",
    ] : []
  )
  cloudbuild_sa_viewer_roles = [
    "roles/browser",
    "roles/iam.securityReviewer",
    "roles/secretmanager.secretViewer",
    "roles/secretmanager.secretAccessor",
  ]
  cloudbuild_sa_editor_roles = concat(
    [
      "roles/compute.xpnAdmin",
      "roles/logging.configWriter",
      "roles/resourcemanager.projectCreator",
    ],
    var.parent_type == "organization" ? [
      "roles/resourcemanager.organizationAdmin",
      "roles/orgpolicy.policyAdmin",
      "roles/resourcemanager.folderCreator",
    ] : [],
    var.parent_type == "folder" ? [
      "roles/resourcemanager.folderAdmin"
    ] : [],
  )
  cloudbuild_devops_roles = [
    # Allow CICD to view all resources within the devops project so it can run terraform plans against them.
    # It won't be able to actually apply any changes unless granted the permission in this list.
    "roles/viewer",

    # Enable Cloud Build SA to list and enable APIs in the devops project.
    "roles/serviceusage.serviceUsageAdmin",
  ]
}

# Cloud Build - API
resource "google_project_service" "services" {
  for_each           = toset(local.services)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# IAM permissions to allow contributors to view the cloud build jobs.
resource "google_project_iam_member" "cloudbuild_builds_viewers" {
  for_each = toset(var.build_viewers)
  project  = var.project_id
  role     = "roles/cloudbuild.builds.viewer"
  member   = each.value
  depends_on = [
    google_project_service.services,
  ]
}

# IAM permissions to allow approvers to edit/create the cloud build jobs.
resource "google_project_iam_member" "cloudbuild_builds_editors" {
  for_each = toset(var.build_editors)
  project  = var.project_id
  role     = "roles/cloudbuild.builds.editor"
  member   = each.value
  depends_on = [
    google_project_service.services,
  ]
}

# IAM permissions to allow approvers and contributors to view logs.
# https://cloud.google.com/cloud-build/docs/securing-builds/store-view-build-logs
resource "google_project_iam_member" "cloudbuild_logs_viewers" {
  for_each = toset(concat(var.build_editors, var.build_viewers))
  project  = var.project_id
  role     = "roles/viewer"
  member   = each.value
  depends_on = [
    google_project_service.services,
  ]
}

# Create the Cloud Source Repository.
resource "google_sourcerepo_repository" "configs" {
  count = local.is_cloud_source_repository ? 1 : 0

  project  = var.project_id
  name     = var.cloud_source_repository.name
  depends_on = [
    google_project_service.services,
  ]
}

resource "google_sourcerepo_repository_iam_member" "readers" {
  for_each = local.is_cloud_source_repository ? toset(var.cloud_source_repository.readers) : []
  project = var.project_id
  repository = google_sourcerepo_repository.configs[0].name
  role = "roles/source.reader"
  member = each.key
}

resource "google_sourcerepo_repository_iam_member" "writers" {
  for_each = local.is_cloud_source_repository ? toset(var.cloud_source_repository.writers) : []
  project = var.project_id
  repository = google_sourcerepo_repository.configs[0].name
  role = "roles/source.writer"
  member = each.key
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

# Cloud Scheduler resources.
# Cloud Scheduler requires an App Engine app created in the project.
# App Engine app cannot be destroyed once created, therefore always create it.
resource "google_app_engine_application" "cloudbuild_scheduler_app" {
  project     = var.project_id
  location_id = var.scheduler_region
  depends_on = [
    google_project_service.services,
  ]
}

# Service Account and its IAM permissions used for Cloud Scheduler to schedule Cloud Build triggers.
resource "google_service_account" "cloudbuild_scheduler_sa" {
  count = local.has_scheduled_jobs ? 1 : 0

  project      = var.project_id
  account_id   = "cloudbuild-scheduler-sa"
  display_name = "Cloud Build scheduler service account"
  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_member" "cloudbuild_scheduler_sa_project_iam" {
  count = local.has_scheduled_jobs ? 1 : 0

  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.cloudbuild_scheduler_sa[0].email}"
  depends_on = [
    google_project_service.services,
  ]
}

# Cloud Build - Cloud Build Service Account IAM permissions

# IAM permissions to allow Cloud Build Service Account use the billing account.
resource "google_billing_account_iam_member" "binding" {
  count = local.has_apply_jobs && var.grant_automation_billing_user_role ? 1 : 0

  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# IAM permissions to allow Cloud Build SA to access state.
resource "google_storage_bucket_iam_member" "cloudbuild_state_iam" {
  bucket = var.state_bucket
  role   = local.has_apply_jobs ? "roles/storage.admin" : "roles/storage.objectViewer"
  member = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the organization.
resource "google_organization_iam_member" "cloudbuild_sa_organization_iam" {
  for_each = var.parent_type == "organization" ? (local.has_apply_jobs ? toset(local.cloudbuild_sa_editor_roles) : toset(local.cloudbuild_sa_viewer_roles)) : []

  org_id   = var.parent_id
  role     = each.value
  member   = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the folder.
resource "google_folder_iam_member" "cloudbuild_sa_folder_iam" {
  for_each = var.parent_type == "folder" ? (local.has_apply_jobs ? toset(local.cloudbuild_sa_editor_roles) : toset(local.cloudbuild_sa_viewer_roles)) : []

  folder   = var.parent_id
  role     = each.value
  member   = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Create Google Cloud Build triggers for specified environments
module "triggers" {
  for_each = {for env in var.envs : env.name => env}
  source  = "./env"

  env                     = each.value.name
  branch_name             = each.value.branch_name
  managed_dirs            = each.value.managed_dirs
  triggers                = each.value.triggers
  cloud_source_repository = {
    name = var.cloud_source_repository.name
  }
  github                  = var.github
  project_id              = var.project_id
  scheduler_region        = var.scheduler_region
  terraform_root          = var.terraform_root
  service_account_email   = local.has_scheduled_jobs ? google_service_account.cloudbuild_scheduler_sa[0].email : ""

  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
    google_sourcerepo_repository.configs,
  ]
}
