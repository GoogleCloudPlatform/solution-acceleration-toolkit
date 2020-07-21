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

# TODO(umairidris): fill in resources and detailed project object schema.
schema = {
  title                = "Recipe for creating GCP projects"
  additionalProperties = false
  properties = {
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
      pattern = "^[0-9]{8,25}$"
    }
    add_parent_folder_dependency = {
      description = <<EOF
        Whether to automatically add dependency on parent folder.
        Only applicable if 'parent_type' is folder. Defaults to false.
        If the parent folder is created in the same config as this project then
        this field should be set to true to create a dependency and pass the
        folder id once it has been created.
      EOF
      type = "boolean"
    }
    project = {
      description          = "Config for the project."
      type                 = "object"
      additionalProperties = false
      properties = {
        project_id = {
          description = "ID of project to create."
          type        = "string"
        }
        apis = {
          description = "APIs to enable in the project."
          type        = "array"
          items = {
            type = "string"
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
        terraform_addons = {
          description = <<EOF
            Additional Terraform configuration for the project deployment.
            For schema see ./deployment.hcl.
          EOF
        }
      }
    }
    deployments = {
      description = <<EOF
        Map of deployment name to resources config.
        Each key will be a directory in the output path.
        For resource schema see ./resources.hcl.
      EOF
      type        = "object"
    }
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
  output_path = "./project"
  flatten {
    key = "project"
  }
  data = {
    enable_terragrunt = true
    {{if and (eq .parent_type "folder") (get . "add_parent_folder_dependency" false)}}
    terraform_addons = {
      deps = [{
        name = "parent_folder"
        path = "../../folder"
        mock_outputs = {
          name = "mock-folder"
        }
      }]
      inputs = {
        folder_id = "$${dependency.parent_folder.outputs.name}"
      }
    }
    {{end}}
  }
}

template "project" {
  component_path = "../components/project"
  output_path    = "./project"
  flatten {
    key = "project"
  }
}

{{range $name, $_ := get . "deployments"}}
template "resources_{{$name}}" {
  recipe_path = "./resources.hcl"
  output_path = "{{$name}}"
  flatten {
    key = "deployments.{{$name}}"
  }
}
{{end}}
