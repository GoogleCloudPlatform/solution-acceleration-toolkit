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

terraform {
  backend "gcs" {}
}

provider "google" {
  version = "~> 3.12.0"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.0"
  project_id   = var.project_id
  network_name = var.network_name

  subnets = [
    {{range .SUBNETS}}
    {
      subnet_name   = "{{.NAME}}"
      subnet_ip     = "{{.IP_RANGE}}"
      subnet_region = var.region
      subnets_private_access = true
    },
    {{end}}
  ]

  secondary_ranges = {
  {{range .SUBNETS}}
    {{if get . "SECONDARY_RANGES"}}
    "{{.NAME}}" = [
      {{range .SECONDARY_RANGES}}
      {
        range_name    = "{{.NAME}}"
        ip_cidr_range = "{{.IP_RANGE}}"
      },
      {{end}}
    ],
    {{end}}
  {{end}}
  }
}
