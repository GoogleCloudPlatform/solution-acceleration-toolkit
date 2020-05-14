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

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 8.0.0"

  name                    = "{{.PROJECT_ID}}"
  org_id                  = var.org_id
  folder_id               = var.folder_id
  billing_account         = var.billing_account
  lien                    = {{get . "ENABLE_LIEN" true}}
  default_service_account = "keep"
  skip_gcloud_download    = true

  {{- if has . "SHARED_VPC"}}
  {{- $host := .SHARED_VPC.HOST_PROJECT_ID}}
  shared_vpc              = "{{$host}}"

  {{- if has .SHARED_VPC "SUBNETS"}}
  shared_vpc_subnets = [
    {{- range get . "SHARED_VPC.SUBNETS"}}
    {{- $region := get . "REGION" $.COMPUTE_NETWORK_REGION}}
    "projects/{{$host}}/regions/{{$region}}/subnetworks/{{.NAME}}",
    {{- end}}
  ]
  {{- end}} {{/* shared VPC subnets */}}
  {{- end}} {{/* shared VPC */}}

  {{- if has . "APIS"}}
  activate_apis = [
    {{- range .APIS}}
    "{{.}}",
    {{- end}}
  ]
  {{- end}}
}
