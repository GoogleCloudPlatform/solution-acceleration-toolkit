# Copyright 2021 Google LLC
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
  required = [
    "admins_group",
    "project",
  ]
  properties = {
    parent_type = {
      description = <<EOF
        Type of parent GCP resource to apply the policy.
        Must be one of 'organization' or 'folder'.
      EOF
      type              = "string"
      pattern           = "^organization|folder$"
      terraformPattern  = "^$|(^organization|folder$)"
    }
    parent_id = {
      description = <<EOF
        ID of parent GCP resource to apply the policy.
        Can be one of the organization ID or folder ID according to parent_type.
        See <https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy> to learn more about resource hierarchy.
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
      required = [
        "project_id",
        "owners_group",
      ]
      properties = {
        project_id = {
          description = "ID of project."
          type        = "string"
          pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
        }
        owners_group = {
          description          = <<EOF
            Group which will be given owner access to the project.
            NOTE: By default, the creating user will be the owner of the project.
            However, this group will own the project going forward. Make sure to include
            yourselve in the group,
          EOF
          type                 = "object"
          additionalProperties = false
          required = [
            "id",
          ]
          properties = {
            id = {
              description = "Email address of the group."
              type        = "string"
            }
            exists = {
              description = "Whether or not the group exists already. It will be created if not."
              type        = "boolean"
              default     = "false"
            }
            customer_id = {
              description = <<EOF
                Customer ID of the organization to create the group in.
                See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
                for how to obtain it.
              EOF
              type        = "string"
            }
            description = {
              description = "Description of the group."
              type        = "string"
            }
            display_name = {
              description = "Display name of the group."
              type        = "string"
            }
            owners = {
              description = "Owners of the group."
              type        = "array"
              items = {
                type = "string"
              }
            }
            # Due to limitations in the underlying module, managers and members
            # are not supported and should be configured in the Google Workspace
            # Admin console.
            # managers = {
            #   description = "Managers of the group."
            #   type        = "array"
            #   items = {
            #     type = "string"
            #   }
            # }
            # members = {
            #   description = "Members of the group."
            #   type        = "array"
            #   items = {
            #     type = "string"
            #   }
            # }
          }
        }
        apis = {
          description = <<EOF
            List of APIs enabled in the devops project.

            NOTE: If a CICD is deployed within this project, then the APIs of
            all resources managed by the CICD must be listed here
            (even if the resources themselves are in different projects).
          EOF
          type        = "array"
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
      description          = <<EOF
        Group which will be given admin access to the folder or organization.
      EOF
      type                 = "object"
      additionalProperties = false
      required = [
        "id",
      ]
      properties = {
        id = {
          description = "Email address of the group."
          type        = "string"
        }
        exists = {
          description = "Whether or not the group exists already. It will be created if not."
          type        = "boolean"
          default     = "false"
        }
        customer_id = {
          description = <<EOF
            Customer ID of the organization to create the group in.
            See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
            for how to obtain it.
          EOF
          type        = "string"
        }
        description = {
          description = "Description of the group."
          type        = "string"
        }
        display_name = {
          description = "Display name of the group."
          type        = "string"
        }
        owners = {
          description = "Owners of the group."
          type        = "array"
          items = {
            type = "string"
          }
        }
        # Due to limitations in the underlying module, managers and members
        # are not supported and should be configured in the Google Workspace
        # Admin console.
        # managers = {
        #   description = "Managers of the group."
        #   type        = "array"
        #   items = {
        #     type = "string"
        #   }
        # }
        # members = {
        #   description = "Members of the group."
        #   type        = "array"
        #   items = {
        #     type = "string"
        #   }
        # }
      }
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
      default     = "false"
    }
  }
}

template "git" {
  component_path = "../components/git"
  output_path    = ".."
}

template "devops" {
  component_path = "../components/devops"
}
