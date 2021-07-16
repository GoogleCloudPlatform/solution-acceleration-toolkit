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
  title                = "IAM members recipe"
  properties = {
    iam_members = {
      description = <<EOF
        [Module](https://github.com/terraform-google-modules/terraform-google-iam)
        
        parent_id should be the following for each type of resource:
        project: project IDs.
        storage_bucket : storage bucket names.
        folder: folder IDs.
        billing_account: billing_account IDs.
        organization: organization IDs.
      EOF
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-iam)"
      type                 = "object"
      additionalProperties = false
      patternProperties = {
        "^storage_bucket|project|organization|folder|billing_account$": {
          type = "array"
          items = {
            type = "object"
            required = [
              "parent_ids",
              "bindings"
            ]
            properties = {
              # parent_id should be the following for each type of resource:
              # project: project IDs.
              # storage_bucket : storage bucket names.
              # folder: folder IDs.
              # billing_account: billing_account IDs.
              # organization: organization IDs.
              parent_ids = {
                description = "IDs of the parent to assign the bindings."
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
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
}

{{if has . "iam_members"}}
template "iam_members" {
  component_path = "../components/iam_members"
}
{{end}}
