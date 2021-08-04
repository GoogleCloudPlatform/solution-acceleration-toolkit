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
  customer_id  = "{{get . "admins_group.customer_id" ""}}"
  description  = "{{get . "admins_group.description" ""}}"
  {{- $default_admins_group_display_name := regexReplaceAll "@.*" (get . "admins_group.id" "") ""}}
  display_name = "{{get . "admins_group.display_name" $default_admins_group_display_name}}"
  exists       = {{get .admins_group "exists" false}}
  id           = "{{.admins_group.id}}"
  owners       = [{{range get . "admins_group.owners"}}"{{.}}",{{end}}]
  managers       = [{{range get . "admins_group.managers"}}"{{.}}",{{end}}]
  members       = [{{range get . "admins_group.members"}}"{{.}}",{{end}}]
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
  {{- $missing_project_owners_group := not (get .project.owners_group "exists")}}
  owners_group = {
    customer_id  = "{{get . "project.owners_group.customer_id" ""}}"
    description  = "{{get . "project.owners_group.description" ""}}"
    {{- $default_project_owners_group_display_name := regexReplaceAll "@.*" (get . "project.owners_group.id" "") ""}}
    display_name = "{{get .project.owners_group "display_name" $default_project_owners_group_display_name}}"
    exists       = {{get .project.owners_group "exists" false}}
    id           = "{{.project.owners_group.id}}"
    owners       = [
      {{- range get . "project.owners_group.owners"}}
      "{{.}}",
      {{- end}}
    ]
    managers       = [
      {{- range get . "project.owners_group.managers"}}
      "{{.}}",
      {{- end}}
    ]
    members       = [
      {{- range get . "project.owners_group.members"}}
      "{{.}}",
      {{- end}}
    ]
  }
  project_id = "{{.project.project_id}}"
}
storage_location = "{{.storage_location}}"
state_bucket = "{{.state_bucket}}"
