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
    "admins_group",
    "project_owners",
  ]
  properties = {
    project_id = {
      description = "Project ID to host devops related resources such as state bucket and CICD."
      type        = "string"
    }
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
    enable_terragrunt = {
      description = <<EOF
        Whether to convert to a Terragrunt deployment. If set to "false", generate Terraform-only
        configs and the CICD pipelines will only use Terraform. Default to "true".
    EOF
      type        = "boolean"
    }
    cicd = {
      description = "Config for CICD. If unset there will be no CICD."
      type        = "object"
      required = [
        "branch_regex",
        "enable_continuous_deployment",
        "enable_triggers",
      ]
      properties = {
        github = {
          description = "Config for GitHub Cloud Build triggers."
          type        = "object"
          properties = {
            owner = {
              description = "GitHub repo owner."
              type        = "string"
            }
            name = {
              description = "GitHub repo name."
              type        = "string"
            }
          }
        }
        cloud_source_repository = {
          description = "Config for Google Cloud Source Repository Cloud Build triggers."
          type        = "object"
          properties = {
            name = {
              description = <<EOF
                Cloud Source Repository repo name.
                The Cloud Source Repository should be hosted under the devops project.
              EOF
              type        = "string"
            }
          }
        }
        branch_regex = {
          description = "Regex of the branches to set the Cloud Build Triggers to monitor."
          type        = "string"
        }
        enable_continuous_deployment = {
          description = "Whether or not to enable continuous deployment of Terraform configs."
          type        = "boolean"
        }
        enable_triggers = {
          description = "Whether or not to enable all Cloud Build triggers."
          type        = "boolean"
        }
        enable_deployment_trigger = {
          description = <<EOF
            Whether or not to enable the post-submit Cloud Build trigger to deploy
            Terraform configs. This is useful when you want to create the Cloud Build
            trigger and manually run it to deploy Terraform configs, but don't want
            it to be triggered automatically by a push to branch. The post-submit
            Cloud Build trigger for deployment will be disabled as long as one of
            `enable_triggers` or `enable_deployment_trigger` is set to `false`.
          EOF
          type        = "boolean"
        }
        terraform_root = {
          description = "Path of the directory relative to the repo root containing the Terraform configs."
          type        = "string"
        }
        build_viewers = {
          description = "IAM members to grant `cloudbuild.builds.viewer` role in the devops project to see CICD results."
          type        = "array"
          items = {
            type = "string"
          }
        }
        managed_services = {
          description = <<EOF
            APIs to enable in the devops project so the Cloud Build service account can manage
            those services in other projects.
          EOF
          type        = "array"
          items = {
            type = "string"
          }
        }
      }
    }
  }
}

template "bootstrap" {
  component_path = "../components/bootstrap"
  output_path    = "./bootstrap"
}

{{if get . "enable_terragrunt" true}}
template "root" {
  component_path = "../components/terragrunt/root"
  output_path    = "./live"
}
{{else}}
template "root" {
  component_path = "../components/terraform/root"
  output_path    = "./live"
}
{{end}}

{{if has . "cicd"}}
template "cicd_manual" {
  component_path = "../components/cicd/manual"
  output_path    = "./cicd"
  flatten {
    key = "cicd"
  }
}

{{if get . "enable_terragrunt" true}}
template "root" {
  component_path = "../components/cicd/terragrunt"
  output_path    = "./cicd"
}
{{end}}

template "cicd_auto" {
  component_path = "../components/cicd/auto"
  output_path    = "./live/cicd"
  flatten {
    key = "cicd"
  }
}
{{end}}
