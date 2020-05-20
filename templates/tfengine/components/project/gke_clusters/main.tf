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

{{range get . "gke_clusters"}}
module "{{resourceName .NAME}}" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "9.0.0"

  # required.
  name                   = "{{.name}}"
  project_id             = var.project_id
  region                 = "{{get . "region" $.gke_cluster_region}}"
  regional               = true
  network                = "{{.network}}"
  subnetwork             = "{{.subnet}}"
  ip_range_pods          = "{{.ip_range_pods_name}}"
  ip_range_services      = "{{.ip_range_services_name}}"
  master_ipv4_cidr_block = "{{.master_ipv4_cidr_block}}"

  # Optional.
  master_authorized_networks = var.master_authorized_networks
  istio                      = true
  skip_provisioners          = true
  enable_private_endpoint    = false
  release_channel            = "STABLE"
}
{{- end}}
