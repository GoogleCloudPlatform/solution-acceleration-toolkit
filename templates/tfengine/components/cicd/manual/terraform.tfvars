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

billing_account               = "{{.billing_account}}"
project_id                    = "{{.project_id}}"
state_bucket                  = "{{.state_bucket}}"
{{- if index . "continuous_deployment_enabled"}}
continuous_deployment_enabled = {{.continuous_deployment_enabled}}
{{- end}}
{{- if index . "trigger_enabled"}}
trigger_enabled               = {{.trigger_enabled}}
{{- end}}
{{- if index . "terraform_root"}}
terraform_root                = "{{.terraform_root}}"
{{- end}}
{{- if index . "build_viewers"}}
build_viewers = [
  {{- range .build_viewers}}
  "{{.}}",
  {{- end}}
]
{{- end}}
