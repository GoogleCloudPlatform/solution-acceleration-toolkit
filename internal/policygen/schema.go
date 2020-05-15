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
      Key value pairs passed to Forseti Policy Library constraint templates.
    type: object
    additionalProperties: false

  gcp_organization_policies:
    description: |
      Key value pairs passed to GCP Organization Policy constraint templates.
    type: object
    additionalProperties: false
    properties:
      ALLOWED_POLICY_MEMBER_DOMAINS:
        description: |
          see templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string

      ALLOWED_SHARED_VPC_HOST_PROJECTS:
        description: |
          see templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string

      ALLOWED_TRUSTED_IMAGE_PROJECTS:
        description: |
          see templates/policygen/org_policies/variables.tf.
        type: array
        items:
          type: string
`
