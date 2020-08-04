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
  title                = "Terraform Deployment Recipe"
  description          = "This recipe should be used to setup a new Terraform deployment directory."
  # Additional properties allowed as this template is usually passed extra fields that are used by other templates.
  properties = {
    state_bucket = {
      description = "State bucket to use for GCS backend."
      type        = "string"
    }
    state_path_prefix = {
      description = "Object path prefix for GCS backend. Defaults to the template's output_path."
      type        = "string"
    }
    terraform_addons = {
      description          = "Extra addons to set in the deployment."
      type                 = "object"
      additionalProperties = false
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
            type                 = "object"
            additionalProperties = false
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
            type                 = "object"
            additionalProperties = false
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
        inputs = {
          description = "Additional inputs to be set in terraform.tfvars"
          type        = "object"
        }
        deps = {
          description = "Additional dependencies on other deployments."
          type        = "array"
          items = {
            type                 = "object"
            additionalProperties = false
            required = [
              "name",
              "path",
            ]
            properties = {
              name = {
                description = "Name of dependency."
                type        = "string"
              }
              path = {
                description = "Path to deployment."
                type        = "string"
              }
              mock_outputs = {
                description = "Mock outputs for the deployment to add."
                type        = "object"
              }
            }
          }
        }
      }
    }
  }
}

template "terraform" {
  component_path = "../components/terraform/main"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}

{{if has . "terraform_addons.vars"}}
template "vars" {
  component_path = "../components/terraform/variables"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}

{{if has . "terraform_addons.outputs"}}
template "outputs" {
  component_path = "../components/terraform/outputs"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}
