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

{{range get . "cloud_sql_instances"}}

{{- $network := .network}}
{{- if has . "network_project_id"}}
{{- $network = printf "projects/%s/global/networks/%s" .network_project_id .network}}
{{- end}}

{{- if eq .type "mysql"}}
module "{{resourceName . "name"}}" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 3.2.0"

  name              = "{{.name}}"
  project_id        = module.project.project_id
  region            = "{{get . "cloud_sql_region" $.cloud_sql_region}}"
  zone              = "{{get . "cloud_sql_zone" $.cloud_sql_zone}}"
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "{{$network}}"
  {{hclField . "user_name"}}
  {{hclField . "user_password"}}
}
{{- end}}
{{- end}}
