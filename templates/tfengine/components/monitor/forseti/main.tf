{{/* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */}}

module "forseti" {
  source  = "terraform-google-modules/forseti/google"
  version = "~> 5.2.1"

  domain     = "{{.domain}}"
  project_id = module.project.project_id
  {{- if eq .parent_type "organization"}}
  org_id     = "{{.parent_id}}"
  {{- else}}
  folder_id  = "{{.parent_id}}"
  {{- end}}
  network_project = "{{.network_project_id}}"
  network         = "{{.network}}"
  subnetwork      = "{{.subnet}}"
  composite_root_resources = [
    {{- if eq .parent_type "organization"}}
    "organizations/{{.parent_id}}",
    {{- else}}
    "folders/{{.parent_id}}",
    {{- end}}
  ]

  server_region           = "{{.compute_region}}"
  cloudsql_region         = "{{.cloud_sql_region}}"
  storage_bucket_location = "{{.storage_location}}"
  bucket_cai_location     = "{{.storage_location}}"

  cloudsql_private  = true
  client_enabled    = false
  server_private    = true
  server_boot_image = "gce-uefi-images/ubuntu-1804-lts"
  server_shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  manage_rules_enabled     = false
  config_validator_enabled = true

  {{- if has . "security_command_center_source_id"}}

  # Enable Security Command Center (SCC) notification.
  cscc_violations_enabled  = true
  cscc_source_id           = "{{.security_command_center_source_id}}"
  {{- end}}
}
