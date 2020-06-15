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
  title = "Org Monitor Recipe"
  required = [
    "project_id",
    "domain",
  ]
  properties = {
    project_id = {
      description = "Project ID to host devops related resources such as state bucket and CICD."
      type        = "string"
    }
    org_id = {
      description = "ID of organization to create project in."
      type        = "string"
    }
    billing_account = {
      description = "ID of billing account to attach to this project."
      type        = "string"
    }
    state_bucket = {
      description = "Name of Terraform remote state bucket."
      type        = "string"
    }
    org_admin = {
      description = "Group who will be given org admin access."
      type        = "string"
      pattern     = "group:.+"
    }
    compute_region = {
      description = "Location of compute instances."
      type        = "string"
    }
    storage_location = {
      description = "Location of storage buckets."
      type        = "string"
    }
    cscc_source_id = {
      description = <<EOF
        CSCC Source ID used for Forseti notification. Follow
        https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification
        to enable Forseti in CSCC and obtain the source ID first.
      EOF
      type        = "string"
    }
  }
}

template "bootstrap" {
  component_path = "../../components/bootstrap"
  output_path    = "./bootstrap"
}

template "root" {
  component_path = "../../components/terragrunt/root"
  output_path    = "./live"
}

{{if has . "cicd"}}
template "cicd_manual" {
  component_path = "../../components/cicd/manual"
  output_path    = "./cicd"
  flatten {
    key = "cicd"
  }
}

template "cicd_auto" {
  component_path = "../../components/cicd/auto"
  output_path    = "./live/cicd"
  flatten {
    key = "cicd"
  }
}
{{end}}
