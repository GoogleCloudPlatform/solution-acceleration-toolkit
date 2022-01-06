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

# Required when using end-user ADCs (Application Default Credentials) to manage Cloud Identity groups and memberships.
provider "google-beta" {
  user_project_override = true
  billing_project       = module.project.project_id
}

{{range .groups}}
module "{{resourceName . "id"}}" {
  source  = "terraform-google-modules/group/google"
  version = "~> 0.4"

  id = "{{.id}}"
  customer_id = "{{.customer_id}}"
  {{- if has . "display_name"}}
  display_name = "{{.display_name}}"
  {{- else}}
  display_name = "{{regexReplaceAll "@.*" .id ""}}"
  {{- end}}
  {{hclField . "description" -}}
  {{hclField . "owners" -}}
  {{hclField . "managers" -}}
  {{hclField . "members" -}}
}
{{end -}}
