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
const schema = `
title: Policy Generator Config Schema
additionalProperties: false
required:
- template_dir
- overall

properties:
  template_dir:
    description: |
      Absolute or relative path to the template directory. If relative, this path
      is relative to the directory where the config file lives.
    type: string

  overall:
    description: |
      Top level configs to control what policies to generate and their enforcing scope.
    type: object
    additionalProperties: false
    properties:
      gcp_org_policies:
        description: |
          Key value pairs to define the scope to apply the policies.
        type: object
        additionalProperties: false
        required:
        - parent_type
        - parent_id
        properties:
          parent_type:
            description: |
              Type of parent GCP resource to apply the policy: can be one of "organization",
              "folder", or "project".
            type: string
            pattern: ^organization|folder|project$

          parent_id:
            description: |
              ID of parent GCP resource to apply the policy: can be one of the organization ID,
              folder ID, or project ID according to parent_type.
            type: string
            pattern: ^[0-9]{8,25}$

      forseti_policies:
        description: |
          Key value pairs to define the scope to apply the policies.
        type: object
        additionalProperties: false
        required:
        - targets
        properties:
          targets:
            description: |
              List of targets to apply the policies, e.g. organization/*,
              organization/123/folder/456.
            type: array
            items:
              type: string

  iam:
    description: |
      Key value pairs to configure IAM related policies. If an optional
      property is not specified, then the corresponding default setting will be applied.
      For example, if allowed_* is not specified, then the corresponding policy will deny all.
    type: object
    additionalProperties: false
    properties:
      allowed_policy_member_customer_ids:
        description: |
          Used in the Google Cloud Organization Policies. See templates/policygen/org_policies/variables.tf.
          Obtain the ID by following https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id.
        type: array
        items:
          type: string

      allowed_policy_member_domains:
        description: |
          Used in the Forseti Policy Library constraints.
          The list of domains to allow users from, e.g. example.com
        type: array
        items:
          type: string

  compute:
    description: |
      Key value pairs to configure compute related policies. If an optional
      property is not specified, then the corresponding default setting will be applied.
      For example, if allowed_* is not specified, then the corresponding policy will deny all.
    type: object
    additionalProperties: false
    properties:
      allowed_shared_vpc_host_projects:
        description: |
          See templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string

      allowed_trusted_image_projects:
        description: |
          See templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string

      allowed_public_vms:
        description: |
          See templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string

      allowed_ip_forwarding_vms:
        description: |
          See templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string
`
