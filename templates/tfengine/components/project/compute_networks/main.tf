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

{{range get . "compute_networks"}}
{{- $has_secondary_ranges := false}}
module "{{resourceName .name}}" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3.0"

  network_name = "{{.name}}"
  project_id   = var.project_id

  {{- if has . "subnets"}}
  subnets = [
    {{- range .subnets}}
    {
      subnet_name            = "{{.name}}"
      subnet_ip              = "{{.ip_range}}"
      {{- if has . "region"}}
      subnet_region          = "{{.region}}"
      {{- else}}
      subnet_region          = "{{$.compute_network_region}}"
      {{- end}}
      subnet_flow_logs       = true
      subnets_private_access = true
    },

    {{- if has . "secondary_ranges"}}
    {{$has_secondary_ranges = true}}
    {{- end}}
    {{- end}}
  ]
  {{- end}}

  {{- if $has_secondary_ranges}}
  secondary_ranges = {
    {{- range .subnets}}
    {{- if has . "secondary_ranges"}}
    "{{.name}}" = [
      {{- range .secondary_ranges}}
      {
        range_name    = "{{.name}}"
        ip_cidr_range = "{{.ip_range}}"
      },
      {{- end}}
    ],
    {{- end}}
    {{- end}}
  }
  {{- end}}
}
{{- end}}
