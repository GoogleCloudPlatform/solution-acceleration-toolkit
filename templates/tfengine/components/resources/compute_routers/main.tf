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

{{range .compute_routers -}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.1.0"

  name         = "{{.name}}"
  project      = module.project.project_id
  region       = "{{get . "compute_region" $.compute_region}}"
  network      = "{{.network}}"

  {{if has . "nats" -}}
  nats = [
    {{- range .nats}}
    {
      name = "{{.name}}"
      {{hclField . "source_subnetwork_ip_ranges_to_nat"}}
      {{- if has . "subnetworks"}}
      subnetworks = [
        {{- range .subnetworks}}
        {
          name = "{{.name}}"
          source_ip_ranges_to_nat  = {{hcl .source_ip_ranges_to_nat}}
          secondary_ip_range_names = []
        },
        {{- end}}
      ]
      {{- end}}
    },
    {{- end}}
  ]
  {{- end}}
}
{{- end}}
