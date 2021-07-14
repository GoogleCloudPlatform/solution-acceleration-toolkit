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

{{range $index, $value := get . "iam_members"}}
module "{{resourceName . "parent_type"}}_iam_members_{{$index}}" {
  {{- if eq .parent_type "storage_bucket"}}
  source = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  storage_buckets = [
    {{- range .parent_ids}}
    "{{.}}",
    {{- end}}
  ]
  {{- else if eq .parent_type "project"}}
  source = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [
    {{- range .parent_ids}}
    "{{.}}",
    {{- end}}
  ]
  {{- else if eq .parent_type "organization"}}
  source = "terraform-google-modules/iam/google//modules/organizations_iam"
  organizations = [
    {{- range .parent_ids}}
    "{{.}}",
    {{- end}}
  ]
  {{- else if eq .parent_type "folder"}}
  source = "terraform-google-modules/iam/google//modules/folders_iam"
  folders = [
    {{- range .parent_ids}}
    "{{.}}",
    {{- end}}
  ]
  {{- else if eq .parent_type "billing_account"}}
  source = "terraform-google-modules/iam/google//modules/billing_accounts_iam"
  billing_account_ids = [
    {{- range .parent_ids}}
    "{{.}}",
    {{- end}}
  ]
  {{- end}}
  mode = "additive"

  bindings = {
    {{range $role, $members := .bindings -}}
    "{{$role}}" = [
      {{range $members -}}
      "{{.}}",
      {{end -}}
    ],
    {{end -}}
  }
}
{{end -}}
