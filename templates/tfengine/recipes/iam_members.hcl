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
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-iam)"
      type                 = "object"
      additionalProperties = false
      patternProperties = {
        "^storage_bucket|project|organization|folder|service_account$": {
          type = "array"
          items = {
            type = "object"
            required = [
              "resource_ids",
              "bindings"
            ]
            properties = {
              resource_ids = {
                description = <<EOF
                  ID of resources to assign the bindings.

                  Should be the following for each resource type:
                    project: project IDs. e.g. [example_project_id]
                    storage_bucket: storage bucket names. e.g. [example_bucket_one, example_bucket_two]
                    folder: folder IDs. e.g. [12345678]
                    organization: organizations IDs. e.g [12345678]
                    service_account: service account emails. e.g [example-sa@example.iam.gserviceaccount.com]
                EOF
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
              project_id = {
                description = <<EOF
                  ID of the project where the resources belong.
                  Currently only required when the resource type is service account.
                EOF
                type  = "string"
              }
            }
          }
        }
      }
    }
    terraform_addons = {
      description = <<EOF
        Additional Terraform configuration for the project deployment.
        For schema see ./deployment.hcl.
      EOF
    }
  }
}

template "deployment" {
  recipe_path = "./deployment.hcl"
  passthrough = [
    "terraform_addons",
  ]
}

template "iam_members" {
  component_path = "../components/iam_members"
}
