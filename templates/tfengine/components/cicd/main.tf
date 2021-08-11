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

{{- $hasScheduledJobs := false}}
{{- $hasApplyJobs := false}}
{{- range .envs}}
  {{- if or (has .triggers "validate.run_on_schedule") (has .triggers "plan.run_on_schedule") (has .triggers "apply.run_on_schedule")}}
    {{- $hasScheduledJobs = true}}
  {{- end}}
  {{- if has .triggers "apply"}}
    {{- $hasApplyJobs = true}}
  {{- end}}
{{- end}}

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
  cloudbuild_sa = "serviceAccount:${data.google_project.devops.number}@cloudbuild.gserviceaccount.com"
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
{{- if has . "cloud_source_repository"}}
    "sourcerepo.googleapis.com",
{{- end}}
{{- if $hasScheduledJobs}}
    "appengine.googleapis.com",
    "cloudscheduler.googleapis.com",
{{- end}}
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
    "roles/resourcemanager.{{.parent_type}}Admin",
    {{- if eq (get . "parent_type") "organization"}}
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderCreator",
    {{- end}}
  ]
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

{{- if has . "build_viewers"}}

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
{{- end}}

{{- if has . "build_editors"}}

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
{{- end}}

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

{{- if has . "cloud_source_repository"}}

# Create the Cloud Source Repository.
resource "google_sourcerepo_repository" "configs" {
  project  = var.project_id
  name     = var.cloud_source_repository.name
  depends_on = [
    google_project_service.services,
  ]
}

{{- if has .cloud_source_repository "readers"}}

resource "google_sourcerepo_repository_iam_member" "readers" {
  for_each = toset(var.cloud_source_repository.readers)
  project = var.project_id
  repository = google_sourcerepo_repository.configs.name
  role = "roles/source.reader"
  member = each.key
}
{{- end}}

{{- if has .cloud_source_repository "writers"}}

resource "google_sourcerepo_repository_iam_member" "writers" {
  for_each = toset(var.cloud_source_repository.writers)
  project = var.project_id
  repository = google_sourcerepo_repository.configs.name
  role = "roles/source.writer"
  member = each.key
}
{{- end}}
{{- end}}

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

{{- if $hasScheduledJobs}}

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
{{- end}}

# Cloud Build - Cloud Build Service Account IAM permissions
{{- if and $hasApplyJobs (get . "grant_automation_billing_user_role" true)}}

# IAM permissions to allow Cloud Build Service Account use the billing account.
resource "google_billing_account_iam_member" "binding" {
  billing_account_id = var.billing_account
  role               = "roles/billing.user"
  member             = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}
{{- end}}

# IAM permissions to allow Cloud Build SA to access state.
resource "google_storage_bucket_iam_member" "cloudbuild_state_iam" {
  bucket = var.state_bucket
  {{- if $hasApplyJobs}}
  role   = "roles/storage.admin"
  {{- else}}
  role   = "roles/storage.objectViewer"
  {{- end}}
  member = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Grant Cloud Build Service Account access to the {{.parent_type}}.
resource "google_{{.parent_type}}_iam_member" "cloudbuild_sa_{{.parent_type}}_iam" {
  {{- if $hasApplyJobs}}
  for_each = toset(local.cloudbuild_sa_editor_roles)
  {{- else}}
  for_each = toset(local.cloudbuild_sa_viewer_roles)
  {{- end}}
  {{- if eq (get . "parent_type") "organization"}}
  org_id   = {{.parent_id}}
  {{- else}}
  folder   = {{.parent_id}}
  {{- end}}
  role     = each.value
  member   = local.cloudbuild_sa
  depends_on = [
    google_project_service.services,
  ]
}

# Create Google Cloud Build triggers for specified environments
module "triggers" {
  for_each = {for env in var.envs:  env.name => env}
  // TODO(ernestognw): Merge triggers to simplify resources #956
  source  = "./triggers"

  env                     = each.value.name
  branch_name             = each.value.branch_name
  managed_dirs            = each.value.managed_dirs
  triggers                = each.value.triggers
  {{- if has . "cloud_source_repository"}}
  cloud_source_repository = var.cloud_source_repository
  {{- end}}
  {{- if has . "github"}}
  github                  = var.github
  {{- end}}
  project_id              = var.project_id
  scheduler_region        = var.scheduler_region
  // TODO(ernestognw): Look how to calculate terraform_root_prefix from terraform_root
  terraform_root          = var.terraform_root
  terraform_root_prefix   = var.terraform_root_prefix
  {{- if $hasScheduledJobs}}
  service_account_email   = "${google_service_account.cloudbuild_scheduler_sa.email}"
  {{- end}}

  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
    {{- if has $ "cloud_source_repository"}}
    google_sourcerepo_repository.configs,
    {{- end}}
  ]
}
