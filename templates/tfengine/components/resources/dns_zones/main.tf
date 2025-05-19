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

{{range get . "dns_zones"}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 6.0.0"

  name       = "{{.name}}"
  project_id = module.project.project_id
  domain     = "{{.domain}}"
  type       = "{{.type}}"

  {{hclField . "private_visibility_config_networks" -}}

  recordsets = {{hcl .record_sets}}
}
{{end -}}
