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

{{range .bastion_hosts -}}
module "{{resourceName .name}}" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-bastion-host.git?ref=umairidris-patch-1"

#   source  = "terraform-google-modules/bastion-host/google"
#   version = "~> 1.0.0"

  name         = "{{.name}}"
  project      = var.project_id
  zone         = "{{get . "region" $.compute_region}}-{{get . "zone" $.compute_zone}}"
  {{- if has . "host_project_id"}}
  host_project = "{{.host_project_id}}"
  {{- else}}
  host_project = var.project_id
  {{- end}}
  network      = "{{.network}}"
  subnet       = "{{.subnet}}"
  image_family = "{{get . "image_family" "ubuntu-2004-lts"}}"
  {{hclField . "members" true}}
  {{hclField . "scopes" false}}

  {{- if has . "startup_script"}}
  startup_script = <<EOF
{{.startup_script}}
EOF
  {{- end}}
}
{{- end}}
