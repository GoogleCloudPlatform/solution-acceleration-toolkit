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

admins_group = {
  {{- if not (get .admins_group "exists" false)}}
  customer_id  = "{{.admins_group.customer_id}}"
  {{- end -}}
  {{hclField .admins_group "description" -}}
  {{- if has .admins_group "display_name"}}
  display_name = "{{.admins_group.display_name}}"
  {{- else}}
  display_name = "{{regexReplaceAll "@.*" .admins_group.id ""}}"
  {{- end}}
  id           = "{{.admins_group.id}}"
  {{hclField .admins_group "owners" -}}
  {{hclField .admins_group "managers" -}}
  {{hclField .admins_group "members" -}}
}
billing_account = "{{.billing_account}}"
parent_id = "{{.parent_id}}"
project = {
  apis = [
    "cloudbuild.googleapis.com",
    "cloudidentity.googleapis.com",
    {{range get . "project.apis" -}}
    "{{.}}",
    {{end -}}
  ]
  owners_group = {
    {{- if or (not (get .admins_group "exists" false)) (not (get .project.owners_group "exists" false))}}
    customer_id  = "{{.project.owners_group.customer_id}}"
    {{- end -}}
    {{hclField .project.owners_group "description" -}}
    {{- if has .project.owners_group "display_name"}}
    display_name = "{{.project.owners_group.display_name}}"
    {{- else}}
    display_name = "{{regexReplaceAll "@.*" .project.owners_group.id ""}}"
    {{- end}}
    id           = "{{.project.owners_group.id}}"
    {{hclField .project.owners_group "owners" -}}
    {{hclField .project.owners_group "managers" -}}
    {{hclField .project.owners_group "members" -}}
  }
  project_id = "{{.project.project_id}}"
}
storage_location = "{{.storage_location}}"
state_bucket = "{{.state_bucket}}"
