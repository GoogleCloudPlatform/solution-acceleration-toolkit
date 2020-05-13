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

{{range get . "COMPUTE_NETWORKS"}}
{{- $has_secondary_ranges := false}}
module "{{resourceName .NAME}}" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3.0"

  network_name = "{{.NAME}}"
  project_id   = var.project_id

  {{- if has . "SUBNETS"}}
  subnets = [
    {{- range .SUBNETS}}
    {
      subnet_name            = "{{.NAME}}"
      subnet_ip              = "{{.IP_RANGE}}"
      {{- if has . "REGION"}}
      subnet_region          = "{{.REGION}}"
      {{- else}}
      subnet_region          = "{{$.COMPUTE_NETWORK_REGION}}"
      {{- end}}
      subnet_flow_logs       = true
      subnets_private_access = true
    },

    {{- if has . "SECONDARY_RANGES"}}
    {{$has_secondary_ranges = true}}
    {{- end}}
    {{- end}}
  ]
  {{- end}}

  {{- if $has_secondary_ranges}}
  secondary_ranges = {
    {{- range .SUBNETS}}
    {{- if has . "SECONDARY_RANGES"}}
    "{{.NAME}}" = [
      {{- range .SECONDARY_RANGES}}
      {
        range_name    = "{{.NAME}}"
        ip_cidr_range = "{{.IP_RANGE}}"
      },
      {{- end}}
    ],
    {{- end}}
    {{- end}}
  }
  {{- end}}
}
{{- end}}
