// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package policygen

// TODO(https://github.com/golang/go/issues/35950): Move this to its own file.

var schema = []byte(`
title = "Policy Generator Config Schema"
additionalProperties = false
required = ["template_dir"]

properties = {
  template_dir = {
    description = <<EOF
      Absolute or relative path to the template directory. If relative, this path
      is relative to the directory where the config file lives.
    EOF
    type = "string"
  }

  forseti_policies = {
    description = "Key value pairs configure Forseti Policy Library constraints."
    type = "object"
    additionalProperties = false
    required = ["targets"]
    properties = {
      targets = {
        description = <<EOF
          List of targets to apply the policies, e.g. organization/*,
          organization/123/folder/456.
        EOF
        type = "array"
        items = {
          type = "string"
        }
      }

      allowed_policy_member_domains = {
        description = "The list of domains to allow users from, e.g. example.com"
        type = "array"
        items = {
          type = "string"
        }
      }
    }
  }

  gcp_org_policies = {}
}
`)

var orgPoliciesSchema = []byte(`
title                = "Google Cloud Organization Policies Config Schema"
additionalProperties = false
required = [
  "allowed_policy_member_customer_ids",
]
properties = {
  parent_type = {
    description = "Type of parent GCP resource to apply the policy: can be one of 'organization', 'folder', or 'project'."
    type = "string"
    pattern = "^organization|folder|project$"
  }

  parent_id = {
    description = <<EOF
      ID of parent GCP resource to apply the policy: can be one of the organization ID,
      folder ID, or project ID according to parent_type.
    EOF
    type = "string"
    pattern = "^[0-9]{8,25}$"
  }

  allowed_policy_member_customer_ids = {
    description = <<EOF
      See templates/policygen/org_policies/variables.tf. Must be specified to restrict domain
      members that can be assigned IAM roles. Obtain the ID by following
      https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id.
    EOF
    type = "array"
    items = {
      type = "string"
    }
  }

  allowed_shared_vpc_host_projects = {
    description = <<EOF
      See templates/policygen/org_policies/variables.tf. If not specified, default to allow all.
    EOF
    type = "array"
    items = {
      type = "string"
    }
  }

  allowed_trusted_image_projects = {
    description = <<EOF
      See templates/policygen/org_policies/variables.tf. If not specified, default to allow all.
    EOF
    type = "array"
    items = {
      type = "string"
    }
  }

  allowed_public_vms = {
    description = <<EOF
      See templates/policygen/org_policies/variables.tf. If not specified, default to deny all.
    EOF
    type = "array"
    items = {
      type = "string"
    }
  }

  allowed_ip_forwarding_vms = {
    description = <<EOF
      See templates/policygen/org_policies/variables.tf. If not specified, default to allow all.
    EOF
    type = "array"
    items = {
      type = "string"
    }
  }
}
`)
