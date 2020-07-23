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

{{range .compute_instance_templates -}}
{{- $template_resource_name := resourceName . "name_prefix" }}
{{- $network_project_id := get . "network_project_id" "${var.project_id}"}}
{{- $subnet := .subnet}}
module "{{$template_resource_name}}" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 4.0.0"

  name_prefix        = "{{.name_prefix}}"
  project_id         = module.project.project_id
  region             = "{{get . "compute_region" $.compute_region}}"
  subnetwork_project = "{{$network_project_id}}"
  subnetwork         = "{{$subnet}}"

  {{- hclField . "machine_type"}}
  {{- hclField . "image_family"}}
  {{- hclField . "image_project"}}
  {{- hclField . "disk_size_gb"}}
  {{- hclField . "disk_type"}}
  {{- hclField . "preemptible"}}

  service_account = {
    email = "{{.service_account}}"
    scopes = ["cloud-platform"]
  }

  {{- if get . "enable_shielded_vm" true}}
  enable_shielded_vm = true
  shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  {{- end}}

  {{- if has . "startup_script"}}
  startup_script = <<EOF
{{.startup_script}}
EOF
  {{- end}}
}

{{- range get . "instances"}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 3.0.0"

  hostname           = "{{.name}}"
  instance_template  = module.{{$template_resource_name}}.self_link
  region             = "{{get . "compute_region" $.compute_region}}"
  subnetwork_project = "{{$network_project_id}}"
  subnetwork         = "{{$subnet}}"
}
{{- end}}
{{- end}}
