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
  title                = "Recipe for iam bindings"
  properties = {
    state_bucket = {
      description = "Bucket to store remote state."
      type        = "string"
    }
    iam_bindings = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-iam)"
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "parent_type",
          "parent_id",
          "bindings"
        ]
        properties = {
          parent_type = {
            description = "Type of the resource to assign the bindings."
            type        = "string"
            pattern     = "^storage_bucket|project|organization|folder|billing_account$"
          }
          parent_ids = {
            description = "Ids of the parent to assign the bindings."
            type        = "array"
            items       = {
              type = "string"
            }
          }
          bindings = {
            description = "Map of IAM role to list of members to grant access to the role."
            type  = "object"
            patternProperties = {
              ".+" = {
                type  = "array" 
                items = {
                  type = "string"
                }
              }
            }
          }
        }
      }
    }
  }
}

{{if has . "iam_bindings"}}
template "iam_bindings" {
  component_path = "../components/iam_bindings"
}
{{end}}
