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

# TODO(xingao): expand schema to all supported fields.
schema = {
  title = "Org Policies Recipe"
  required = [
    "allowed_policy_member_customer_ids"
  ]
  properties = {
    parent_type = {
      description = "Type of parent GCP resource to apply the policy: can be one of 'organization', 'folder', or 'project'."
      type        = "string"
      pattern     = "^organization|folder|project$"
    }

    allowed_policy_member_customer_ids = {
      description = <<EOF
        See templates/policygen/org_policies/variables.tf. Must be specified to restrict domainmembers that can be assigned IAM roles.
        Obtain the ID by following https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id.
      EOF
      type = "array"
      items = {
        type = "string"
      }
    }
  }
}

template "terragrunt" {
  recipe_path = "../deployment/terragrunt.hcl"
  output_path    = "./org_policies"
}

template "org_policies" {
  component_path = "../../../policygen/org_policies"
  output_path    = "./org_policies"
}
