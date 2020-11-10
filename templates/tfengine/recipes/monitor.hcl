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

schema = {
  title                = "Monitor Recipe"
  additionalProperties = false
  properties = {
    project = {
      description          = "Config of project to host monitoring resources"
      type                 = "object"
      additionalProperties = false
      properties = {
        project_id = {
          description = "ID of project."
          type        = "string"
        }
      }
    }
    forseti = {
      description          = "Config for the Forseti instance."
      type                 = "object"
      additionalProperties = false
      properties = {
        domain = {
          description = "Domain for the Forseti instance."
          type        = "string"
        }
        network_project_id = {
          description = "Name of network project. If unset, will use the current project."
          type        = "string"
        }
        network = {
          description = "Name of the bastion host's network."
          type        = "string"
        }
        subnet = {
          description = "Name of the bastion host's subnet."
          type        = "string"
        }
        security_command_center_source_id = {
          description = <<EOF
            Security Command Center (SCC) Source ID used for Forseti notification.
            To enable viewing Forseti violations in SCC:

              1) Omit this field initially, generate the Terraform configs and do a
                full deployment of Forseti;

              2) Follow
              [the guide](https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification)
                to enable Forseti in SCC (you need a valid Forseti instance to do so)
                and obtain the SCC source ID;

              3) Add the ID through this field, generate the Terraform configs and
                deploy Forseti again.
          EOF
          type        = "string"
        }
      }
    }
    cloud_sql_region = {
      description = "Location of cloud sql instances."
      type        = "string"
    }
    compute_region = {
      description = "Location of compute instances."
      type        = "string"
    }
    storage_location = {
      description = "Location of storage buckets."
      type        = "string"
    }
  }
}

template "project" {
  recipe_path = "./project.hcl"
}

template "forseti" {
  component_path = "../components/monitor/forseti"
  flatten {
    key = "forseti"
  }
}
