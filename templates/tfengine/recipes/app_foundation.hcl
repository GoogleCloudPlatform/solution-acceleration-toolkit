# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: This example is still under development and is not considered stable!
# Breaking changes to components for this example will not be part of releases.

template "app" {
  recipe_path = "./app.hcl"
  data = {
    deployments = [
      {{if has .res "gke_clusters"}}
      {
        name = "project_networks",
        resources = {
          project = {
            name_suffix        = "networks"
            is_shared_vpc_host = true
            apis               = ["compute.googleapis.com"]
          }
          compute_networks = [{
            name = "primary"
            subnets = [
              {{range get . "res.gke_clusters"}}
              {
                name     = "{{.name}}-subnet"
                ip_range = "{{.subnet_ip_range}}"
                secondary_ranges = [
                  {
                    name     = "pods-range"
                    ip_range = "{{.pods_secondary_ip_range}}"
                  },
                  {
                    name     = "services-range"
                    ip_range = "{{.services_secondary_ip_range}}"
                  }
                ]
              },
              {{end}}
            ]
          }]
        }
      },
      {{end}}
      {{if has .res "gke_clusters"}}
      {
        name = "project_apps",
        resources = {
          project = {
            name_suffix = "apps"
            shared_vpc_attachment = {
              host_project_suffix = "networks"
            }
            apis = ["compute.googleapis.com"]
          }
          gke_clusters = [
            {{range get .res "gke_clusters"}}
            {
            name                   = "{{.name}}"
            network_project_id     = "networks"
            network                = "primary"
            subnet                 = "{{.name}}-subnet"
            ip_range_pods_name     = "pods-range"
            ip_range_services_name = "services-range"
            master_ipv4_cidr_block = "{{.master_ipv4_cidr_block}}"
            },
            {{end}}
          ]
          binary_authorization = {}
        }
      },
      {{end}}
    ]
  }
}
