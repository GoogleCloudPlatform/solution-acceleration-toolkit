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
        providers = {
          description = "Custom provider and version constraints."
          type = "array"
          items = {
            type                 = "object"
            additionalProperties = false
            required = [
              "name",
              "version_constraints",
            ]
            properties = {
              name = {
                description = "Name of provider, e.g. google, google-beta."
                type        = "string"
              }
              version_constraints = {
                description = <<EOF
                  Provider version constraints,e.g. ">= 1.2.0, < 2.0.0".
                  Follow <https://www.terraform.io/docs/language/expressions/version-constraints.html> for syntax.
                EOF
                type        = "string"
              }
            }
          }
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
        states = {
          description = <<EOF
            Additional terraform_remote_state block to set in main.tf.
            This block can be used to fetch dynamic outputs generated by other deployments.
          EOF
          type = "array"
          items = {
            type                 = "object"
            additionalProperties = false
            required = [
              "prefix",
            ]
            properties = {
              prefix = {
                description = <<EOF
                  Prefix of the state to fetch.
                  It is the `state_path_prefix` set for a deployment or the `output_path`
                  if `state_path_prefix` is not set.
                EOF
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
  component_path = "../components/terraform/main"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
  {{if has . "resources"}}
  flatten {
    key = "resources"
  }
  {{end}}
}

// The key "terraform_addons" could be flattened at one level above
// where "deployment.hcl" recipe is used, e.g. "project.hcl".
// "deployment.hcl" can also be directly used, in which case "terraform_addons"
// is not flattened.
{{if or (has . "vars") (has . "terraform_addons.vars")}}
template "vars" {
  component_path = "../components/terraform/variables"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}

// The key "terraform_addons" could be flattened at one level above
// where "deployment.hcl" recipe is used, e.g. "project.hcl".
// "deployment.hcl" can also be directly used, in which case "terraform_addons"
// is not flattened.
{{if or (has . "outputs") (has . "terraform_addons.outputs")}}
template "outputs" {
  component_path = "../components/terraform/outputs"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}

// The key "terraform_addons" could be flattened at one level above
// where "deployment.hcl" recipe is used, e.g. "project.hcl".
// "deployment.hcl" can also be directly used, in which case "terraform_addons"
// is not flattened.
{{if or (has . "states") (has . "terraform_addons.states")}}
template "states" {
  component_path = "../components/terraform/states"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}
