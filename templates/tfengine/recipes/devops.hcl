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
      description = "Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'."
      type        = "string"
      pattern     = "^organization|folder$"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy: can be one of the organization ID,
        folder ID according to parent_type.
      EOF
      type        = "string"
      pattern     = "^[0-9]{8,25}$"
    }
    billing_account = {
      description = "ID of billing account to attach to this project."
      type        = "string"
    }
    project = {
      description          = "Config for the project to host devops related resources such as state bucket and CICD."
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
          type = "array"
          items = {
            type = "string"
          }
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
    enable_bootstrap_gcs_backend = {
      description = <<EOF
        Whether to enable GCS backend for the bootstrap deployment. Defaults to false.
        Since the bootstrap deployment creates the state bucket, it cannot back the state
        to the GCS bucket on the first deployment. Thus, this field should be set to true
        after the bootstrap deployment has been applied. Then the user can run `terraform init`
        in the bootstrapd deployment to transfer the state from local to GCS.
      EOF
      type       = "boolean"
    }
  }
}

template "bootstrap" {
  component_path = "../components/bootstrap"
}
