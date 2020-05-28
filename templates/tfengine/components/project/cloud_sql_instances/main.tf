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
{{- $instance_resource_name := resourceName .name}}

{{- $network := .network}}
{{- if has . "network_project_id"}}
{{- $network = printf "projects/%s/global/networks/%s" .network_project_id .network}}
{{- end}}

{{- if eq .type "mysql"}}
module "{{$instance_resource_name}}" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 3.2.0"

  name              = "{{.name}}"
  project_id        = var.project_id
  region            = "{{get . "region" $.cloud_sql_region}}"
  zone              = "{{get . "zone" $.cloud_sql_zone}}"
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "{{$network}}"
  {{hclField . "user_name" false}}
  {{hclField . "user_password" false}}
}

{{- range get . "users"}}
resource "google_sql_user" "{{resourceName .name}}" {
  name     = "{{.name}}"
  instance = module.{{$instance_resource_name}}.instance_name
  host     = "%"
  password = "{{.password}}"
  project  = var.project_id
}
{{- end}}
{{- end}}
{{- end}}
