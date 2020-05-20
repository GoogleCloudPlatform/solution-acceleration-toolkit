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

# This folder contains Terraform resources to configure GCP Organization Policies.
# (https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
# See the following resources for the details of policies enforced.

{{- $type_field := printf "%s_id" .PARENT_TYPE}}

# App Engine
module "orgpolicy_appengine_disable_code_download" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/appengine.disableCodeDownload"
  policy_type = "boolean"
  enforce     = true
}

# Cloud SQL
module "orgpolicy_sql_restrict_authorized_networks" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/sql.restrictAuthorizedNetworks"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_sql_restrict_public_ip" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/sql.restrictPublicIp"
  policy_type = "boolean"
  enforce     = true
}

# Compute Engine
module "orgpolicy_compute_disable_nested_virtualization" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/compute.disableNestedVirtualization"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_disable_serial_port_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/compute.disableSerialPortAccess"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_restrict_shared_vpc_host_projects" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint        = "constraints/compute.restrictSharedVpcHostProjects"
  policy_type       = "list"
  allow             = var.allowed_shared_vpc_host_projects
  allow_list_length = length(var.allowed_shared_vpc_host_projects)
}

module "orgpolicy_compute_skip_default_network_creation" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/compute.skipDefaultNetworkCreation"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_trusted_image_projects" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint        = "constraints/compute.trustedImageProjects"
  policy_type       = "list"
  allow             = var.allowed_trusted_image_projects
  allow_list_length = length(var.allowed_trusted_image_projects)
}

module "orgpolicy_compute_vm_can_ip_forward" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint        = "constraints/compute.vmCanIpForward"
  policy_type       = "list"
  allow             = var.allowed_ip_forwarding_vms
  allow_list_length = length(var.allowed_ip_forwarding_vms)
}

module "orgpolicy_compute_vm_external_ip_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint        = "constraints/compute.vmExternalIpAccess"
  policy_type       = "list"
  allow             = var.allowed_public_vms
  allow_list_length = length(var.allowed_public_vms)
}

module "orgpolicy_compute_restrict_xpn_project_lien_removal" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "constraints/compute.restrictXpnProjectLienRemoval"
  policy_type = "boolean"
  enforce     = true
}

# Cloud Identity and Access Management
data "google_organization" "orgs" {
  for_each = toset(var.allowed_policy_member_domains)
  domain   = each.value
}

module "orgpolicy_iam_allowed_policy_member_domains" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint        = "constraints/iam.allowedPolicyMemberDomains"
  policy_type       = "list"
  allow             = [for org in data.google_organization.orgs : org["directory_customer_id"]]
  allow_list_length = length(var.allowed_policy_member_domains)
}

# Google Cloud Platform - Resource Locations
module "orgpolicy_gcp_resource_locations" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint        = "constraints/gcp.resourceLocations"
  policy_type       = "list"
  allow             = ["in:us-locations"]
  allow_list_length = 1
}

# Cloud Storage
module "orgpolicy_storage_uniform_bucket_level_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for = "{{.PARENT_TYPE}}"
  {{$type_field}} = "{{.PARENT_ID}}"

  constraint  = "storage.uniformBucketLevelAccess"
  policy_type = "boolean"
  enforce     = true
}
