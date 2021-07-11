# Copyright 2021 Google LLC
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

build_editors   = [
  {{- if has . "build_editors"}}
  {{- range .build_editors}}
  "{{.}}",
  {{- end}}
  {{- end}}
]
build_viewers   = [
  {{- if has . "build_viewers"}}
  {{- range .build_viewers}}
  "{{.}}",
  {{- end}}
  {{- end}}
]
{{- if has . "cloud_source_repository"}}
cloud_source_repostory = {
  name = "{{.cloud_source_repository.name}}"
  {{- if has .cloud_source_repository "readers"}}
  readers = [
    {{- range .cloud_source_repository.readers}}
    "{{.}}",
    {{- end}}
  ]
  {{- end}}
  {{- if has .cloud_source_repository "readers"}}
  writers = [
    {{- range .cloud_source_repository.writers}}
    "{{.}}",
    {{- end}}
  ]
  {{- end}}
}
{{- end}}
{{- if has . "github"}}
github = {
  owner = "{{.github.owner}}"
  name = "{{.github.name}}"
}
{{- end}}
billing_account   = "{{.billing_account}}"
project_id        = "{{.project_id}}"
scheduler_region  = "{{.scheduler_region}}"
state_bucket      = "{{.state_bucket}}"
terraform_root    = "{{.terraform_root}}"
