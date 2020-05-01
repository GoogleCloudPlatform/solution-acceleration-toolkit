# Copyright 2020 Google Inc.
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

{{range get . "DEPS" -}}
dependency "{{.NAME}}" {
  config_path = "{{.PATH}}"

  {{- if not (get . "MOCK_OUTPUTS")}}
  skip_outputs = true
  {{- end}}

  {{- if index . "MOCK_OUTPUTS"}}
  mock_outputs = {
    {{- range $k, $v := .MOCK_OUTPUTS}}
    {{$k}} = {{$v}}
    {{- end}}
  }
  {{- end}}
}
{{- end}}

{{if index . "INPUTS" -}}
inputs = {
  {{- range $k, $v := .INPUTS}}
  {{$k}} = {{$v}}
  {{- end}}
}
{{- end}}
