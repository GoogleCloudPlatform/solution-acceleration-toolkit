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
  title = "Devops Recipe"
  required = [
    "parent_type",
    "parent_id",
    "project_id",
    "billing_account",
    "admin",
    "project_owners",
  ]
  properties = {
    project_id = {
      description = "Project ID to host devops related resources such as state bucket and CICD."
      type        = "string"
    }
    parent_type = {
      description = "Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'."
      type = "string"
      pattern = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy: can be one of the organization ID,
        folder ID according to parent_type.
      EOF
      type = "string"
      pattern = "^[0-9]{8,25}$"
    }
    billing_account = {
      description = "ID of billing account to attach to this project."
      type        = "string"
    }
    state_bucket = {
      description = "Name of Terraform remote state bucket."
      type        = "string"
    }
    storage_location = {
      description = "Location of state bucket."
      type        = "string"
    }
    admin = {
      description = "Group who will be given org admin access."
      type        = "string"
      pattern     = "group:.+"
    }
    # TODO(xingao): expand CICD schema.
    cicd = {
      description = "Config for CICD. If unset there will be no CICD."
      type        = "object"
    }
  }
}

template "bootstrap" {
  component_path = "../components/bootstrap"
  output_path    = "./bootstrap"
}

template "root" {
  component_path = "../components/terragrunt/root"
  output_path    = "./live"
}

{{if has . "cicd"}}
template "cicd_manual" {
  component_path = "../components/cicd/manual"
  output_path    = "./cicd"
  flatten {
    key = "cicd"
  }
}

template "cicd_auto" {
  component_path = "../components/cicd/auto"
  output_path    = "./live/cicd"
  flatten {
    key = "cicd"
  }
}
{{end}}
