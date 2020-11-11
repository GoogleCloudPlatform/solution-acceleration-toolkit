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
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  {{- if has . "shared_vpc_attachment"}}
  source  = "terraform-google-modules/project-factory/google//modules/shared_vpc"
  version = "~> 9.2.0"
  {{- else}}
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 9.2.0"
  {{- end}}

  {{- if get . "use_constants"}}

  name            = "${local.constants.project_prefix}-${local.constants.env_code}-{{.name_suffix}}"
  org_id          = ""
  folder_id       = local.constants.folder_id
  billing_account = local.constants.billing_account
  {{- else}}

  name                    = "{{.project_id}}"
  {{- if eq .parent_type "organization"}}
  org_id                  = "{{.parent_id}}"
  {{- else}}
  org_id                  = ""
  folder_id               = "{{.parent_id}}"
  {{- end}}
  billing_account         = "{{.billing_account}}"
  {{- end}}
  lien                    = {{get . "enable_lien" true}}
  default_service_account = "keep"
  skip_gcloud_download    = true

  {{- if get . "is_shared_vpc_host"}}
  enable_shared_vpc_host_project = true
  {{- end}}

  {{- if has . "shared_vpc_attachment"}}
  {{- if get . "use_constants"}}
  {{$host := printf "${local.constants.project_prefix}-${local.constants.env_code}-%s" .shared_vpc_attachment.host_project_suffix}}
  shared_vpc              = "{{$host}}"
  {{- if has . "shared_vpc_attachment.subnets"}}
  shared_vpc_subnets = [
    {{- range get . "shared_vpc_attachment.subnets"}}
    "projects/{{$host}}/regions/${local.constants.compute_region}/subnetworks/{{.name}}",
    {{- end}}
  ]
  {{- end}}
  {{- else}}
  {{$host := get .shared_vpc_attachment "host_project_id"}}
  shared_vpc              = "{{$host}}"
  {{- if has . "shared_vpc_attachment.subnets"}}
  shared_vpc_subnets = [
    {{- range get . "shared_vpc_attachment.subnets"}}
    {{- $region := get . "compute_region" $.compute_region}}
    "projects/{{$host}}/regions/{{$region}}/subnetworks/{{.name}}",
    {{- end}}
  ]
  {{- end}}
  {{- end}}
  {{- end}}
  activate_apis = {{- if has . "apis"}} {{hcl .apis}} {{- else}} [] {{end}}
}
