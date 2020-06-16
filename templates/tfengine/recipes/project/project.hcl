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
  title       = "Recipe for creating GCP projects."
  description = "See schema for fields in ../project/base_project.hcl."
}

{{/* TODO(umairidris): Consider stopping doing this */}}
{{$base := ""}}
{{if eq .parent_type "folder"}}
{{$base = .project.project_id}}
{{end}}

template "terragrunt" {
  recipe_path = "../deployment/terragrunt.hcl"
  output_path = "{{$base}}/project"
  {{if has . "project"}}
  flatten {
    key = "project"
  }
  {{end}}
  {{if eq .parent_type "folder"}}
  data = {
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
  }
  {{end}}
}

template "project" {
  component_path = "../../components/project/project"
  output_path    = "{{$base}}/project"
  flatten {
    key = "project"
  }
}

{{range $name, $_ := get . "deployments"}}
template "resources_{{$name}}" {
  recipe_path = "../project/resources.hcl"
  output_path = "{{$base}}/{{$name}}"
  flatten {
    key = "deployments"
  }
  flatten {
    key = "{{$name}}"
  }
}
{{end}}
