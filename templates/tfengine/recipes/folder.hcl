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
  title = "Recipe for creating GCP folders."
  required = [
    "parent_type",
    "parent_id",
    "display_name",
  ]
  properties = {
    parent_type = {
      description = "Type of parent GCP resource to apply the policy: can be one of 'organization' or 'folder'."
      type    = "string"
      pattern = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy: can be one of the organization ID or folder ID according to parent_type.
      EOF
      type    = "string"
      pattern = "^[0-9]{8,25}$"
    }
    display_name = {
      description = "Name of folder."
      type        = "string"
    }
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
  output_path = "./folder"
  data = {
    enable_terragrunt = true
    {{if eq .parent_type "folder"}}
    terraform_addons = {
      deps = [{
        name = "parent_folder"
        path = "../../folder"
        mock_outputs = {
          name = "mock-folder"
        }
      }]
      inputs = {
        parent = "$${dependency.parent_folder.outputs.name}"
      }
    }
    {{end}}
  }
}

template "folder" {
  component_path = "../components/folder"
  output_path    = "./folder"
  data = {
    display_name = "{{.display_name}}"
    {{if eq .parent_type "organization"}}
    parent       =  "organizations/{{.parent_id}}"
    {{end}}
  }
}
