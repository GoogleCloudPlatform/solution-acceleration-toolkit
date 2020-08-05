# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

schema = {
  title                = "Google Cloud Organization Policy Recipe"
  additionalProperties = false
  required = [
    "allowed_policy_member_customer_ids",
  ]
  properties = {
    parent_type = {
      description = "Type of parent GCP resource to apply the policy: can be one of 'organization', 'folder', or 'project'."
      type        = "string"
      pattern     = "^organization|folder|project$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy: can be one of the organization ID,
        folder ID, or project ID according to parent_type.
      EOF
      type        = "string"
      pattern     = "^[0-9]{8,25}$"
    }
    allowed_policy_member_customer_ids = {
      description = <<EOF
        See templates/policygen/org_policies/variables.tf. Must be specified to restrict domain
        members that can be assigned IAM roles. Obtain the ID by following
        https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    allowed_shared_vpc_host_projects = {
      description = <<EOF
        See templates/policygen/org_policies/variables.tf. If not specified, default to allow all.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    allowed_trusted_image_projects = {
      description = <<EOF
        See templates/policygen/org_policies/variables.tf. If not specified, default to allow all.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    allowed_public_vms = {
      description = <<EOF
        See templates/policygen/org_policies/variables.tf. If not specified, default to deny all.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    allowed_ip_forwarding_vms = {
      description = <<EOF
        See templates/policygen/org_policies/variables.tf. If not specified, default to allow all.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    output_path = {
      description = "For internal use. Default state path prefix for Terraform Engine deployments."
      type        = "string"
    }
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
}

template "org_policies" {
  component_path = "../components/org_policies"
}
