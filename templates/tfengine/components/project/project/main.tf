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

  {{- if has . "SHARED_VPC_ATTACHMENT"}}
  {{- $host := .SHARED_VPC_ATTACHMENT.HOST_PROJECT_ID}}
  shared_vpc              = "{{$host}}"

  shared_vpc_subnets = [
    {{- range get . "SHARED_VPC_ATTACHMENT.SUBNETS"}}
    {{- $region := get . "REGION" $.COMPUTE_NETWORK_REGION}}
    "projects/{{$host}}/regions/{{$region}}/subnetworks/{{.NAME}}",
    {{- end}}
  ]
  {{- end}}

  {{- if has . "APIS"}}
  activate_apis = [
    {{- range .APIS}}
    "{{.}}",
    {{- end}}
  ]
  {{- end}}
}

{{if get . "IS_SHARED_VPC_HOST" -}}
resource "google_compute_shared_vpc_host_project" "host" {
  project = module.project.project_id
}
{{- end}}
