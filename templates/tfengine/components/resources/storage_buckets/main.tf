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

{{range get . "storage_buckets"}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "{{.name}}"
  project_id = module.project.project_id
  location   = "{{get . "storage_location" $.storage_location}}"

  {{- if index . "iam_members"}}
  iam_members = [
    {{- range .iam_members}}
    {
      role   = "{{.role}}"
      member = "{{.member}}"
    },
    {{- end}}
  ]
  {{- end}}
}
{{end}}
