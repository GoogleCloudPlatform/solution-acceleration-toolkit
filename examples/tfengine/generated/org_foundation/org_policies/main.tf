# This folder contains Terraform resources to configure GCP Organization Policies.
# (https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
# See the following resources for the details of policies enforced.

# App Engine
module "orgpolicy_appengine_disable_code_download" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/appengine.disableCodeDownload"
  policy_type = "boolean"
  enforce     = true
}

# Cloud SQL
module "orgpolicy_sql_restrict_authorized_networks" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/sql.restrictAuthorizedNetworks"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_sql_restrict_public_ip" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/sql.restrictPublicIp"
  policy_type = "boolean"
  enforce     = true
}

# Compute Engine
module "orgpolicy_compute_disable_nested_virtualization" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.disableNestedVirtualization"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_disable_serial_port_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.disableSerialPortAccess"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_skip_default_network_creation" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.skipDefaultNetworkCreation"
  policy_type = "boolean"
  enforce     = true
}

module "orgpolicy_compute_vm_external_ip_access" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint        = "constraints/compute.vmExternalIpAccess"
  policy_type       = "list"
  allow             = var.allowed_public_vms
  allow_list_length = length(var.allowed_public_vms)
}

module "orgpolicy_compute_restrict_xpn_project_lien_removal" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/compute.restrictXpnProjectLienRemoval"
  policy_type = "boolean"
  enforce     = true
}

# Cloud Identity and Access Management
module "orgpolicy_iam_allowed_policy_member_domains" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint        = "constraints/iam.allowedPolicyMemberDomains"
  policy_type       = "list"
  allow             = var.allowed_policy_member_customer_ids
  allow_list_length = length(var.allowed_policy_member_customer_ids)
}
module "orgpolicy_disable_service_account_key_creation" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/iam.disableServiceAccountKeyCreation"
  policy_type = "boolean"
  enforce     = true
}

# Google Cloud Platform - Resource Locations
module "orgpolicy_gcp_resource_locations" {
  source  = "terraform-google-modules/org-policy/google"
  version = "~> 3.0.2"

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
  version = "~> 3.0.2"

  policy_for      = "organization"
  organization_id = "12345678"

  constraint  = "constraints/storage.uniformBucketLevelAccess"
  policy_type = "boolean"
  enforce     = true
}
