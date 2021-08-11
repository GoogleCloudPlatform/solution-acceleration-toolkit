{{- /* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}
{{$missing_admins_group := not (get .admins_group "exists") -}}
admins_group = {
  id           = "{{.admins_group.id}}"
  {{if $missing_admins_group -}}
  display_name = "{{get .admins_group "display_name" (regexReplaceAll "@.*" .admins_group.id "")}}"
  customer_id  = "{{.admins_group.customer_id}}"
  {{hclField .admins_group "description" -}}
  {{hclField .admins_group "owners" -}}
  {{hclField .admins_group "managers" -}}
  {{hclField .admins_group "members" -}}
  {{- end -}}
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
    id           = "{{.project.owners_group.id}}"
    {{if $missing_project_owners_group -}}
    display_name = "{{get .project.owners_group "display_name" (regexReplaceAll "@.*" .project.owners_group.id "")}}"
    customer_id  = "{{.project.owners_group.customer_id}}"
    {{hclField .project.owners_group "description" -}}
    {{hclField .project.owners_group "owners" -}}
    {{hclField .project.owners_group "managers" -}}
    {{hclField .project.owners_group "members" -}}
    {{- end -}}
  }
  project_id = "{{.project.project_id}}"
}
storage_location = "{{.storage_location}}"
state_bucket = "{{.state_bucket}}"
