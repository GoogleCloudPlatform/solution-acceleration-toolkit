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
  title                = "Devops Recipe"
  additionalProperties = false
  properties = {
    parent_type = {
      description = <<EOF
        Type of parent GCP resource to apply the policy.
        Must be one of 'organization' or 'folder'.
      EOF
      type        = "string"
      pattern     = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy.
        Can be one of the organization ID or folder ID according to parent_type.
      EOF
      type        = "string"
      pattern     = "^[0-9]{8,25}$"
    }
    billing_account = {
      description = "ID of billing account to attach to this project."
      type        = "string"
    }
    project = {
      description          = "Config for the project to host devops resources such as remote state and CICD."
      type                 = "object"
      additionalProperties = false
      properties = {
        project_id = {
          description = "ID of project."
          type        = "string"
        }
        owners = {
          description = <<EOF
            List of members to transfer ownership of the project to.
            NOTE: By default the creating user will be the owner of the project.
            Thus, there should be a group in this list and you must be part of that group,
            so a group owns the project going forward.
          EOF
          type        = "array"
          items = {
            type = "string"
          }
        }
        apis = {
          description = <<EOF
            List of APIs enabled in the devops project.

            NOTE: If a CICD is deployed within this project, then the APIs of
            all resources managed by the CICD must be listed here
            (even if the resources themselves are in different projects).
          EOF
        }
      }
    }
    state_bucket = {
      description = "Name of Terraform remote state bucket."
      type        = "string"
    }
    storage_location = {
      description = "Location of state bucket."
      type        = "string"
    }
    admins_group = {
      description = "Group who will be given org admin access."
      type        = "string"
    }
    enable_gcs_backend = {
      description = <<EOF
        Whether to enable GCS backend for the devops module.
        Defaults to false.

        Since the devops module creates the state bucket, it cannot back up
        the state to the GCS bucket on the first module. Thus, this field
        should be set to false initially.

        After the devops module has been applied once and the state bucket
        exists, the user should set this to true and regenerate the configs.

        To migrate the state from local to GCS, run `terraform init` on the
        module.
      EOF
      type        = "boolean"
    }
  }
}

template "devops" {
  component_path = "../components/devops"
}
