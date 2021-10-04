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

resource "google_project_service" "servicenetworking" {
  service            = "servicenetworking.googleapis.com"
  project            = module.project.project_id
  disable_on_destroy = false
}

{{range $index, $worker_pool := get . "private_worker_pools" -}}
{{$name := resourceName . "name" -}}
module "{{$name}}_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.3.0"

  network_name = "{{$worker_pool.name}}-network"
  project_id   = module.project.project_id

  subnets = []
}

resource "google_compute_global_address" "{{$name}}_address" {
  provider      = google-beta
  name          = "{{$worker_pool.name}}-address"
  purpose       = "VPC_PEERING"
  network       = module.{{$name}}_network.network_self_link
  address_type  = "INTERNAL"
  address       = "{{$worker_pool.pool_address}}"
  prefix_length = {{$worker_pool.pool_prefix_length}}
  project       = module.project.project_id
}

resource "google_service_networking_connection" "{{$name}}_connection" {
  network                 = module.{{$name}}_network.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.{{$name}}_address.name]
  depends_on              = [google_project_service.servicenetworking]
}

resource "google_compute_network_peering_routes_config" "{{$name}}_peering" {
  network              = module.{{$name}}_network.network_name
  peering              = "servicenetworking-googleapis-com"
  import_custom_routes = false
  export_custom_routes = true
  project              = module.project.project_id
  depends_on = [
    google_service_networking_connection.{{$name}}_connection,
    module.{{$name}}_network,
  ]
}

module "private_pool_gcloud" {
  source                 = "terraform-google-modules/gcloud/google"
  version                = "~> 3.0.1"
  additional_components  = []
  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "builds worker-pools create private-pool --region={{$.compute_region}} --peered-network=projects/$${module.project.project_id}/global/networks/$${module.{{$name}}_network.network_name} --project=$${module.project.project_id} --quiet"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "builds worker-pools delete private-pool --region={{$.compute_region}}  --project=$${module.project.project_id} --quiet"
  module_depends_on = [
    google_compute_network_peering_routes_config.{{$name}}_peering,
  ]
}

{{- if has $worker_pool "gke_vpn_connection"}}
module "{{$name}}_vpn_ha_1" {
  source           = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version          = "~> 1.5.0"
  project_id       = module.project.project_id
  region           = "{{$.compute_region}}"
  network          = module.{{$name}}_network.network_self_link
  name             = "{{$worker_pool.name}}-net-to-{{$worker_pool.gke_vpn_connection.gke_name}}-net"
  peer_gcp_gateway = module.{{$name}}_vpn_ha_2.self_link
  router_asn       = {{sub 64514 $index}}
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.1"
        asn     = {{sub 64513 $index}}
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "{{$worker_pool.pool_address}}/{{$worker_pool.pool_prefix_length}}" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.1.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = null
      shared_secret                   = ""
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.1"
        asn     = {{sub 64513 $index}}
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "{{$worker_pool.pool_address}}/{{$worker_pool.pool_prefix_length}}" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.2.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = null
      shared_secret                   = ""
    }
  }
}

module "{{$name}}_vpn_ha_2" {
  source           = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version          = "~> 1.5.0"
  project_id       = module.project.project_id
  region           = "{{$.compute_region}}"
  network          = "{{$worker_pool.gke_vpn_connection.gke_network}}"
  name             = "{{$worker_pool.gke_vpn_connection.gke_name}}-net-to-{{$worker_pool.name}}-net"
  router_asn       = {{sub 64513 $index}}
  peer_gcp_gateway = module.{{$name}}_vpn_ha_1.self_link
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = {{sub 64514 $index}}
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "{{$worker_pool.gke_vpn_connection.gke_control_plane_range}}" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.1.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = null
      shared_secret                   = module.{{$name}}_vpn_ha_1.random_secret
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = {{sub 64514 $index}}
      }
      bgp_peer_options = {
        advertise_mode = "CUSTOM"
        advertise_ip_ranges = {
          "{{$worker_pool.gke_vpn_connection.gke_control_plane_range}}" : ""
        }
        route_priority   = 1000
        advertise_groups = null
      }
      bgp_session_range               = "169.254.2.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = null
      shared_secret                   = module.{{$name}}_vpn_ha_1.random_secret
    }
  }
}
{{- end}}
{{end -}}
