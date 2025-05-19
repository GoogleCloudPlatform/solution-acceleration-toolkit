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

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = ">= 3.0"
    google-beta = ">= 3.0"
    kubernetes  = "~> 2.10"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "org_policies"
  }
}

# This folder contains Terraform resources to configure GCP Organization Policies.
# (https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
# See the following resources for the details of policies enforced.

# App Engine
module "orgpolicy_appengine_disable_code_download" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/appengine.disableCodeDownload"
  policy_type = "boolean"
  enforce     = true
}

# Cloud SQL
module "orgpolicy_sql_restrict_authorized_networks" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/sql.restrictAuthorizedNetworks"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_sql_restrict_public_ip" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/sql.restrictPublicIp"
  policy_type = "boolean"
  enforce     = true
}

# Compute Engine
module "orgpolicy_compute_disable_nested_virtualization" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.disableNestedVirtualization"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_disable_serial_port_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.disableSerialPortAccess"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_skip_default_network_creation" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.skipDefaultNetworkCreation"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_vm_external_ip_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint        = "constraints/compute.vmExternalIpAccess"
  policy_type       = "list"
  allow             = var.allowed_public_vms
  allow_list_length = length(var.allowed_public_vms)
}

module "orgpolicy_compute_restrict_xpn_project_lien_removal" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.restrictXpnProjectLienRemoval"
  policy_type = "boolean"
  enforce     = true
}

# Cloud Identity and Access Management
module "orgpolicy_iam_allowed_policy_member_domains" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint        = "constraints/iam.allowedPolicyMemberDomains"
  policy_type       = "list"
  allow             = var.allowed_policy_member_customer_ids
  allow_list_length = length(var.allowed_policy_member_customer_ids)
}

# https://medium.com/@jryancanty/stop-downloading-google-cloud-service-account-keys-1811d44a97d9
module "orgpolicy_disable_service_account_key_creation" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/iam.disableServiceAccountKeyCreation"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_disable_service_account_key_upload" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/iam.disableServiceAccountKeyUpload"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_disable_automatic_iam_grants_for_default_service_accounts" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/iam.automaticIamGrantsForDefaultServiceAccounts"
  policy_type = "boolean"
  enforce     = true
}

# Google Cloud Platform - Resource Locations
module "orgpolicy_gcp_resource_locations" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint        = "constraints/gcp.resourceLocations"
  policy_type       = "list"
  allow             = ["in:us-locations"]
  allow_list_length = 1
}

# Cloud Storage
module "orgpolicy_storage_uniform_bucket_level_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "<= 7"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/storage.uniformBucketLevelAccess"
  policy_type = "boolean"
  enforce     = true
}
