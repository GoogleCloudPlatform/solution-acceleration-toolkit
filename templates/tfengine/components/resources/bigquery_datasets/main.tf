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

{{range get . "bigquery_datasets"}}
module "{{resourceName . "dataset_id"}}" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.2.0"

  dataset_id = "{{.dataset_id}}"
  project_id = module.project.project_id
  location   = "{{get . "bigquery_location" $.bigquery_location}}"
  {{hclField . "default_table_expiration_ms"}}

  {{hclField . "access"}}
}
{{- end}}
