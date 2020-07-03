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
  title                = "Org Monitor Recipe"
  additionalProperties = false
  properties = {
    project = {
    # project_id = {
    #  description = "ID of the project to host monitoring resources."
    #  type        = "string"
    #}

    }
  forseti = {

  }
    domain = {
      description = "Domain for the Forseti instance."
      type        = "string"
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
    security_command_center_source_id = {
      description = <<EOF
        Security Command Center (SCC) Source ID used for Forseti notification.
        To enable viewing Forseti violations in SCC:
          1) Omit this field initially, generate the Terraform configs and do a
             full deployment of Forseti;
          2) Follow https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification
             to enable Forseti in SCC (you need a valid Forseti instance to do so)
             and obtain the SCC source ID;
          3) Add the ID through this field, generate the Terraform configs and
             deploy Forseti again.
      EOF
      type        = "string"
    }
  }
}

template "project" {
  recipe_path = "./project.hcl"
  output_path = "./monitor"
}

template "forseti" {
  component_path = "../components/monitor/forseti"
  output_path    = "./monitor/forseti"
}
