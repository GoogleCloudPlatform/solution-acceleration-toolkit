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
  title                = "Project Recipe"
  additionalProperties = false
  required = [
    "project",
  ]
  properties = {
    state_bucket = {
      description = "Bucket to store remote state."
      type        = "string"
    }
    state_path_prefix = {
      description = "Path within bucket to store state. Defaults to the template's output_path."
      type        = "string"
    }
    parent_type = {
      description = <<EOF
        Type of parent GCP resource to apply the policy
        Can be one of 'organization' or 'folder'.
      EOF
      type    = "string"
      pattern = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy
        Can be one of the organization ID or folder ID according to parent_type.
      EOF
      type    = "string"
    }
    project = {
      description          = "Config for the project."
      type                 = "object"
      additionalProperties = false
      required = [
        "project_id",
      ]
      properties = {
        project_id = {
          description = "ID of project to create and/or provision resources in."
          type        = "string"
          pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
        }
        exists = {
          description = "Whether this project exists. Defaults to 'false'."
          type        = "boolean"
        }
        apis = {
          description = "APIs to enable in the project."
          type        = "array"
          items = {
            type = "string"
          }
        }
        api_identities = {
          description = <<EOF
            The list of service identities (Google Managed service account for the API) to
            force-create for the project (e.g. in order to grant additional roles).
            APIs in this list will automatically be appended to `apis`.
            Not including the API in this list will follow the default behaviour for identity
            creation (which is usually when the first resource using the API is created).
            Any roles (e.g. service agent role) must be explicitly listed.
            See <https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles>
            for a list of related roles.
          EOF
          type        = "array"
          items = {
            type = "object"
            additionalProperties = false
            properties = {
              api = {
                type = "string"
              }
              roles = {
                description = "Roles to granted to the API Service Agent."
                type        = "array"
                items = {
                  type = "string"
                }
              }
            }
          }
        }
        is_shared_vpc_host = {
          description = "Whether this project is a shared VPC host. Defaults to 'false'."
          type        = "boolean"
        }
        shared_vpc_attachment = {
          description          = "If set, treats this project as a shared VPC service project."
          type                 = "object"
          additionalProperties = false
          required = [
            "host_project_id",
          ]
          properties = {
            host_project_id = {
              description = "ID of host project to connect this project to."
              type        = "string"
              pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
            }
            subnets = {
              description = "Subnets within the host project to grant this project access to."
              type        = "array"
              items = {
                type                 = "object"
                additionalProperties = false
                required = [
                  "name",
                ]
                properties = {
                  name = {
                    description = "Name of subnet."
                    type        = "string"
                  }
                  compute_region = {
                    description = "Region of subnet."
                    type        = "string"
                  }
                }
              }
            }
          }
        }
      }
    }
    resources = {
      description = <<EOF
        Resources in this project.
        See [resources.md](./resources.md) for schema.
      EOF
    }
    terraform_addons = {
      description = <<EOF
        Additional Terraform configuration for the project deployment.
        For schema see ./deployment.hcl.
      EOF
    }
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
}


{{- if not (get .project "exists" false)}}
template "project" {
  component_path = "../components/project"
  flatten {
    key = "project"
  }
}
{{end}}

{{if has . "resources"}}
template "resources" {
  recipe_path = "./resources.hcl"
  flatten {
    key = "resources"
  }
}
{{end}}
