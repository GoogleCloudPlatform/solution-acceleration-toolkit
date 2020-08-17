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
  source  = "terraform-google-modules/project-factory/google//modules/shared_vpc"
  version = "~> 9.0.0"

  name                    = "{{.project_id}}"
  {{if eq .parent_type "organization" -}}
  org_id                  = "{{.parent_id}}"
  {{else -}}
  org_id                  = ""
  folder_id               = "{{.parent_id}}"
  {{end -}}
  billing_account         = "{{.billing_account}}"
  lien                    = {{get . "enable_lien" true}}
  default_service_account = "keep"
  skip_gcloud_download    = true
  {{if has . "shared_vpc_attachment" -}}
  {{$host := .shared_vpc_attachment.host_project_id -}}
  shared_vpc              = "{{$host}}"
  {{if has . "shared_vpc_attachment.subnets" -}}
  shared_vpc_subnets = [
    {{range get . "shared_vpc_attachment.subnets" -}}
    {{$region := get . "compute_region" $.compute_region -}}
    "projects/{{$host}}/regions/{{$region}}/subnetworks/{{.name}}",
    {{end -}}
  ]
  {{end -}}
  {{end -}}
  activate_apis = [
    {{range get . "apis" -}}
    "{{.}}",
    {{end -}}
  ]
}
{{if get . "is_shared_vpc_host"}}
resource "google_compute_shared_vpc_host_project" "host" {
  project = module.project.project_id
}
{{end -}}
