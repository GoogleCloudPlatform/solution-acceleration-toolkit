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
{{$missing_admins_group := not (get .admins_group "exists")}}
admins_group = {
  {{- if $missing_admins_group}}
  customer_id  = "{{.admins_group.customer_id}}"
  {{- end -}}
  {{hclField .admins_group "description"}}
  display_name = "{{get .admins_group "display_name" (regexReplaceAll "@.*" .admins_group.id "")}}"
  id           = "{{.admins_group.id}}"
  {{hclField .admins_group "owners" -}}
  {{hclField .admins_group "managers" -}}
  {{hclField .admins_group "members" -}}
}
{{hclField . "billing_account" -}}
{{hclField . "parent_id" -}}
project = {
  apis = [
    "cloudbuild.googleapis.com",
    "cloudidentity.googleapis.com",
    {{range get . "project.apis" -}}
    "{{.}}",
    {{end -}}
  ]
  owners_group = {
    {{- $missing_project_owners_group := not (get .project.owners_group "exists")}}
    {{- if or $missing_admins_group $missing_project_owners_group}}
    customer_id  = "{{.project.owners_group.customer_id}}"
    {{- end}}
    {{hclField .project.owners_group "description" -}}
    display_name = "{{get .project.owners_group "display_name" (regexReplaceAll "@.*" .project.owners_group.id "")}}"
    id           = "{{.project.owners_group.id}}"
    {{hclField .project.owners_group "owners" -}}
    {{hclField .project.owners_group "managers" -}}
    {{hclField .project.owners_group "members" -}}
  }
  project_id = "{{.project.project_id}}"
}
{{hclField . "storage_location" -}}
{{hclField . "state_bucket" -}}
