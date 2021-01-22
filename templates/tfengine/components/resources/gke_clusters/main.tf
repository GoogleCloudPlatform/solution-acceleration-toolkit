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

data "google_client_config" "default" {}

{{range get . "gke_clusters"}}
provider "kubernetes" {
  alias                  = "{{resourceName . "name"}}"
  load_config_file       = false
  host                   = "https://${module.{{resourceName . "name"}}.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.{{resourceName . "name"}}.ca_certificate)
}

module "{{resourceName . "name"}}" {
  # TODO(https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/issues/695):
  # Pin to stable version once released.
  # source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  # version = "~> 13.0.0"
  source  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/safer-cluster-update-variant?ref=81b0a9491d51546eedc6c1aabd368dc085c16b5e"

  providers = {
    kubernetes = kubernetes.{{resourceName . "name"}}
  }

  # Required.
  name                   = "{{.name}}"
  project_id             = module.project.project_id
  {{- if get $ "use_constants"}}
  region                 = local.constants.gke_region
  {{- else}}
  region                 = "{{get . "gke_region" (get $ "gke_region")}}"
  {{- end}}
  regional               = true
  {{hclField . "network_project_id"}}
  {{- if has . "network_project_suffix"}}
  network_project_id = "${local.constants.project_prefix}-${local.constants.env_code}-{{.network_project_suffix}}"
  {{- end}}
  network                = "{{.network}}"
  subnetwork             = "{{.subnet}}"
  ip_range_pods          = "{{.ip_range_pods_name}}"
  ip_range_services      = "{{.ip_range_services_name}}"
  master_ipv4_cidr_block = "{{.master_ipv4_cidr_block}}"
  {{hclField . "master_authorized_networks" -}}
  {{hclField . "istio" -}}
  skip_provisioners          = true
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

  depends_on = [
    module.project
  ]
}
{{end -}}
