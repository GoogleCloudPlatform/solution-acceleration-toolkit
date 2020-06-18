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
  title       = "Terragrunt Deployment Recipe."
  description = "This recipe should be used to setup a new Terraform deployment directory."
  properties = {
    disable_gcs_backend_config = {
      description = "Whether to omit the GCS backend block. Defaults to false."
      type        = "boolean"
    }
    state_bucket = {
      description = "State bucket to use for GCS backend."
      type        = "string"
    }
    terraform_addons = {
      description = "Extra addons to set in the deployment."
      type        = "object"
      properties = {
        raw_config = {
          description = <<EOF
            Raw text to insert in the Terraform main.tf file.
            Can be used to add arbitrary blocks or resources that the engine does not support.
          EOF
          type        = "string"
        }
        vars = {
          description = "Additional vars to set in the deployment in variables.tf."
          type = "array"
          items = {
            type = "object"
            required = [
              "name",
              "type",
            ]
            properties = {
              name = {
                description = "Name of the variable."
                type        = "string"
              }
              type = {
                description = "Type of variable."
                type        = "string"
              }
              value = {
                description = "Value of variable to set in terraform.tfvars."
              }
              terragrunt_input = {
                description = "Value of variable set in terragrunt.hcl."
              }
              default = {
                description = "Default value of variable."
              }
            }
          }
        }
        outputs = {
          description = "Additional outputs to set in outputs.tf."
          type = "array"
          items = {
            type = "object"
            required = [
              "name",
              "value",
            ]
            properties = {
              name = {
                description = "Name of output."
                type        = "string"
              }
              value = {
                description = "Value of output."
                type        = "string"
              }
            }
          }
        }
      }
    }
  }
}

template "terraform" {
  recipe_path = "./terraform_deployment.hcl"
  data = {
    # GCS backend config is set by terragrunt root.
    disable_gcs_backend_config = true
  }
}

template "terragrunt" {
  component_path = "../components/terragrunt/leaf"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
