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

{{range get . "GKE_CLUSTERS"}}
module "{{resourceName .NAME}}" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "9.0.0"

  # Required.
  name                   = "{{.NAME}}"
  project_id             = var.project_id
  region                 = "{{get . "REGION" $.GKE_CLUSTER_REGION }}"
  regional               = true
  network                = "{{.NETWORK}}"
  subnetwork             = "{{.SUBNET}}"
  ip_range_pods          = "{{.IP_RANGE_PODS_NAME}}"
  ip_range_services      = "{{.IP_RANGE_SERVICES_NAME}}"
  master_ipv4_cidr_block = "{{.MASTER_IPV4_CIDR_BLOCK}}"

  # Optional.
  master_authorized_networks = var.master_authorized_networks
  istio                      = true
  skip_provisioners          = true
  enable_private_endpoint    = false
  release_channel            = "STABLE"
}
{{- end}}
