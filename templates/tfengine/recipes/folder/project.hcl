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

template "terragrunt" {
  recipe_path = "../terraform/terragrunt.hcl"
  output_path = "{{.project.project_id}}/project"
  data = {
    deps = [{
      name = "parent_folder"
      path = "../../folder"
      mock_outputs = {
        name = "\"mock-folder\""
      }
    }]
    inputs = {
      folder_id = "dependency.parent_folder.outputs.name"
    }
  }
  {{if has . "project"}}
  flatten {
    key = "project"
  }
  {{end}}
}

template "project" {
  component_path = "../../components/project/project"
  output_path    = "{{.project.project_id}}/project"
  flatten {
    key = "project"
  }
}

{{if has . "resources"}}
template "resources" {
  recipe_path = "../project/resources.hcl"
  output_path = "./{{.project.project_id}}/resources"
  flatten {
    key = "resources"
  }
}
{{end}}

{{if index . "project_owners"}}
template "owners" {
  component_path = "../../components/project/owners"
  output_path    = "{{.project.project_id}}/project"
}
{{end}}
