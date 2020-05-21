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
- org_id

properties:
  template_dir:
    description: |
      Absolute or relative path to the template directory. If relative, this path
      is relative to the directory where the config file lives.
    type: string

  org_id:
    description: |
      ID of the organization where the policies will be applied to.
    type: string
    pattern: ^[0-9]{8,25}$

  forseti_policies:
    description: |
      Key value pairs passed to Forseti Policy Library constraint templates. If an optional
      property is not specified, then the corresponding default setting will be applied.
    type: object
    additionalProperties: false
    properties:
      allowed_policy_member_domains:
        description: |
          List of domains to allow their members to be granted IAM roles.
          gserviceaccount.com is always allowed to make sure GCP internal services work properly.
        type: array
        items:
          type: string

  gcp_organization_policies:
    description: |
      Key value pairs passed to GCP Organization Policy constraint templates. If an optional
      property is not specified, then the corresponding default setting will be applied.
      For example, if ALLOWED_* is not specified, then the corresponding policy will deny all.
    type: object
    additionalProperties: false
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

      allowed_policy_member_domains:
        description: |
          See templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string

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
