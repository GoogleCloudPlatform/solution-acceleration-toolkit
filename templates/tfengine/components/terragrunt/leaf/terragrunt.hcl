# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include {
  path = find_in_parent_folders()
}

{{- range get . "deps"}}

dependency "{{.name}}" {
  config_path = "{{.path}}"

  {{- if not (get . "mock_outputs")}}
  skip_outputs = true
  {{- end}}

  {{- if index . "mock_outputs"}}
  mock_outputs = {
    {{- range $k, $v := .mock_outputs}}
    {{$k}} = {{hcl $v}}
    {{- end}}
  }
  {{- end}}
}
{{- end}}

inputs = {
  {{- range $k, $v:= get . "inputs"}}
  {{$k}} = {{hcl $v}}
  {{- end}}

  {{- range get . "vars"}}
  {{- if has . "terragrunt_input"}}
  {{.name}} = {{hcl .terragrunt_input}}
  {{- end}}
  {{- end}}
}
