# Copyright 2021 Google LLC
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
  title                = "Folder Recipe"
  additionalProperties = false
  required = [
    "folders",
  ]
  properties = {
    parent_type = {
      description = <<EOF
        Type of parent GCP resource to apply the policy.
        Can be one of 'organization' or 'folder'.
      EOF
      type    = "string"
      pattern = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy.
        Can be one of the organization ID or folder ID according to parent_type.
      EOF
      type    = "string"
      pattern = "^[0-9]{8,25}$"
    }
    folders = {
      description = "Folders to create."
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "display_name"
        ]
        properties = {
          display_name = {
            description = "Name of folder."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized display_name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          parent = {
            description = "Parent of folder."
            type        = "string"
          }
        }
      }
    }
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
}

template "folder" {
  component_path = "../components/folders"
  data = {
    {{if eq .parent_type "organization"}}
    parent       =  "organizations/{{.parent_id}}"
    {{else}}
    parent       = "folders/{{.parent_id}}"
    {{end}}
  }
}
