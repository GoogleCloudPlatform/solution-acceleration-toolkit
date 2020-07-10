{{- /* Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

{{- /* TODO(umairidris): add helpers for auto secrets for auto generating strings and passwords */}}

{{range get . "secrets" -}}
{{- $resource_name := resourceName . "secret_id"}}
resource "google_secret_manager_secret" "{{$resource_name}}" {
  provider = google-beta

  secret_id = "{{.secret_id}}"
  project   = module.project.project_id

  replication {
    {{- if has . "locations"}}
    user_managed {
      {{- range .locations}}
      location = "{{.}}"
      {{- end}}
    }
    {{- else}}
    automatic = true
    {{- end}}
  }
}

{{if has . "secret_data" -}}
resource "google_secret_manager_secret_version" "{{$resource_name}}_data" {
  provider = google-beta

  secret      = google_secret_manager_secret.{{$resource_name}}.id
  secret_data = "{{.secret_data}}"
}
{{- end}}
{{- end}}
