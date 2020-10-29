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

template "devops" {
  component_path = "../components/app/devops"
  output_path = "./devops"
  flatten {
    key = "devops"
  }
}

template "cicd" {
  component_path = "../components/app/cicd"
  output_path = "./cicd"
}

template "cicd_configs" {
  component_path = "../components/cicd/configs"
  output_path    = "./cicd/configs"
  data = {
    managed_dirs = [
      "devops",
      "cicd",
      {{range $deployment := .deployments}}
      {{range $env, $_ := $.constants}}
      {{if not (eq $env "shared")}}
      "{{$deployment.name}}/envs/{{$env}}",
      {{end}}
      {{end}}
      {{end}}
    ]
  }
}

template "constants" {
  component_path = "../components/app/constants"
  output_path    = "./constants"
}

{{range $i, $deployment := .deployments}}
{{range $env, $_ := $.constants}}
{{if not (eq $env "shared")}}
template "env" {
  component_path = "../components/app/env"
  output_path    = "{{$deployment.name}}/envs/{{$env}}"
  data = {
    env        = "{{$env}}"
    deployment = "{{$deployment.name}}"
  }
}
{{end}}
{{end}}

template "main_module" {
  component_path = "../components/app/main_module"
  output_path    = "{{$deployment.name}}/modules/main"
}

{{if has $deployment "resources"}}
template "project" {
  component_path = "../components/project"
  output_path    = "{{$deployment.name}}/modules/main"
  data = {
    use_constants = true
    parent_type   = "folder"
  }
  flatten {
    key   = "deployments"
    index = {{$i}}
  }
  flatten {
    key = "resources"
  }
  flatten {
    key = "project"
  }
}

template "resources" {
  recipe_path = "./resources.hcl"
  output_path = "{{$deployment.name}}/modules/main"
  flatten {
    key   = "deployments"
    index = {{$i}}
  }
  flatten {
    key = "resources"
  }
}
{{end}}
{{end}}
