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

# This folder contains Terraform resources to setup the devops project, which includes:
# - The project itself,
# - APIs to enable,
# - Deletion lien,
# - Project level IAM permissions for the project owners,
# - A Cloud Storage bucket to store Terraform states for all deployments,
# - Admin permission at {{.parent_type}} level,
# - Cloud Identity groups and memberships, if requested.

// TODO: replace with https://github.com/terraform-google-modules/terraform-google-bootstrap
terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
{{- if get . "enable_gcs_backend"}}
  backend "gcs" {
    bucket = "{{.state_bucket}}"
    prefix = "devops"
  }
{{- end}}
}

{{- $missing_admins_group := not (get .admins_group "exists")}}
{{- $missing_project_owners_group := not (get .project.owners_group "exists")}}
{{- if or $missing_admins_group $missing_project_owners_group}}

# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = var.project.project_id
}
{{- end}}

# Create the project, enable APIs, and create the deletion lien, if specified.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.2.2"

  name            = var.project.project_id
  {{- if eq .parent_type "organization"}}
  org_id          = var.parent_id
  {{- else}}
  org_id          = ""
  folder_id       = var.parent_id
  {{- end}}
  billing_account = var.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  activate_apis = var.project.apis
}

# Terraform state bucket, hosted in the devops project.
module "state_bucket" {
source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = var.state_bucket
  project_id = module.project.project_id
  location   = var.storage_location
}

{{- if $missing_project_owners_group}}

# Devops project owners group.
module "owners_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id = var.project.owners_group.id
  customer_id = var.project.owners_group.customer_id
  display_name = var.project.owners_group.display_name
  {{- if has .project.owners_group "description"}}
  description = var.project.owners_group.description
  {{- end }}
  {{- if has .project.owners_group "owners"}}
  owners = var.project.owners_group.owners
  {{- end }}
  {{- if has .project.owners_group "managers"}}
  managers = var.project.owners_group.managers
  {{- end }}
  {{- if has .project.owners_group "members"}}
  members = var.project.owners_group.members
  {{- end }}
  depends_on = [
    module.project
  ]
}

# The group is not ready for IAM bindings right after creation. Wait for
# a while before it is used.
resource "time_sleep" "owners_wait" {
  depends_on = [
    module.owners_group,
  ]
  create_duration = "15s"
}
{{- end}}

# Project level IAM permissions for devops project owners.
resource "google_project_iam_binding" "devops_owners" {
  project = module.project.project_id
  role    = "roles/owner"
  {{- if get .project.owners_group "exists" false}}
  members = ["group:${var.project.owners_group.id}"]
  {{- else}}
  members = ["group:${module.owners_group.id}"]
  depends_on = [time_sleep.owners_wait]
  {{- end}}
}

{{- if $missing_admins_group}}

# Admins group for at {{.parent_type}} level.
module "admins_group" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.1"

  id = var.admins_group.id
  customer_id = var.admins_group.customer_id
  display_name = var.admins_group.display_name
  {{- if has .admins_group "description"}}
  description = var.admins_group.description
  {{- end }}
  {{- if has .admins_group "owners"}}
  owners = var.admins_group.owners
  {{- end }}
  {{- if has .admins_group "managers"}}
  managers = var.admins_group.managers
  {{- end }}
  {{- if has .admins_group "members"}}
  members = var.admins_group.members
  {{- end }}
  depends_on = [
    module.project
  ]
}

# The group is not ready for IAM bindings right after creation. Wait for
# a while before it is used.
resource "time_sleep" "admins_wait" {
  depends_on = [
    module.admins_group,
  ]
  create_duration = "15s"
}
{{- end}}

# Admin permission at {{.parent_type}} level.
resource "google_{{.parent_type}}_iam_member" "admin" {
  {{- if eq .parent_type "organization"}}
  org_id = var.parent_id
  {{- else}}
  folder = "folders/${var.parent_id}"
  {{- end}}
  role   = "roles/resourcemanager.{{.parent_type}}Admin"
  {{- if get .admins_group "exists" false}}
  member = "group:${var.admins_group.id}"
  {{- else}}
  member = "group:${module.admins_group.id}"
  depends_on = [time_sleep.admins_wait]
  {{- end}}
}
