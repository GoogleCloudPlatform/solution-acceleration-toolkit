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

{{- if get . "exists"}}
module "project" {
  source = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0.0"

  project_id =  "{{.project_id}}"
  activate_apis = {{- if has . "apis"}} {{hcl .apis}} {{- else}} [] {{end}}
}
{{- else -}}
# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0.0"

  name            = "{{.project_id}}"
  {{- if eq .parent_type "organization"}}
  org_id          = "{{.parent_id}}"
  {{- else}}
  org_id          = ""
  folder_id       = "{{.parent_id}}"
  {{- end}}
  billing_account = "{{.billing_account}}"
  lien            = {{get . "enable_lien" true}}
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  {{- if get . "is_shared_vpc_host"}}
  enable_shared_vpc_host_project = true
  {{- end}}

  {{- if has . "shared_vpc_attachment"}}
  {{$host := get .shared_vpc_attachment "host_project_id"}}
  svpc_host_project_id = "{{$host}}"
  {{- if has . "shared_vpc_attachment.subnets"}}
  shared_vpc_subnets = [
    {{- range get . "shared_vpc_attachment.subnets"}}
    {{- $region := get . "compute_region" $.compute_region}}
    "projects/{{$host}}/regions/{{$region}}/subnetworks/{{.name}}",
    {{- end}}
  ]
  {{- end}}
  {{- end}}
  activate_apis = {{- if has . "apis"}} {{hcl .apis}} {{- else}} [] {{end}}

  {{- if has . "api_identities"}}
  activate_api_identities = {{hcl .api_identities}}
  {{end}}
  {{if $labels := merge (get $ "labels") (get . "labels") -}}
  labels = {
    {{range $k, $v := $labels -}}
    {{$k}} = "{{$v}}"
    {{end -}}
  }
  {{end -}}
}
{{- end}}
