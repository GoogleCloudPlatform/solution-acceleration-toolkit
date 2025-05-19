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

data "google_client_config" "default" {}

{{range get . "gke_clusters"}}
provider "kubernetes" {
  alias                  = "{{resourceName . "name"}}"
  host                   = "https://${module.{{resourceName . "name"}}.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.{{resourceName . "name"}}.ca_certificate)
}

module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "~> 36.3.0"

  providers = {
    kubernetes = kubernetes.{{resourceName . "name"}}
  }

  # Required.
  name                   = "{{.name}}"
  project_id             = module.project.project_id
  region                 = "{{get . "gke_region" (get $ "gke_region")}}"
  regional               = true
  {{hclField . "network_project_id"}}
  network                = "{{.network}}"
  subnetwork             = "{{.subnet}}"
  ip_range_pods          = "{{.ip_range_pods_name}}"
  ip_range_services      = "{{.ip_range_services_name}}"
  master_ipv4_cidr_block = "{{.master_ipv4_cidr_block}}"
  {{hclField . "master_authorized_networks" -}}
  {{hclField . "istio" -}}
  enable_private_endpoint    = false
  release_channel            = "STABLE"
  {{if has . "service_account" -}}
  compute_engine_service_account = "{{.service_account}}"
  {{end -}}

  {{if $labels := merge (get $ "labels") (get . "labels") -}}
  cluster_resource_labels = {
    {{range $k, $v := $labels -}}
    {{$k}} = "{{$v}}"
    {{end -}}
  }
  {{end -}}

  {{if has . "node_pools" -}}
  node_pools = [
    {{range $_, $pool := .node_pools -}}
    {
    {{range $k, $v := $pool -}}
      {{$k}} = "{{$v}}"
    {{end -}}
    },
    {{end -}}
  ]
  {{- end}}

  depends_on = [
    module.project
  ]
}
{{end -}}
