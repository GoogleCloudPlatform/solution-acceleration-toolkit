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

# {{$recipes := "../../templates/tfengine/recipes"}}

data = {
  parent_type      = "folder" # One of `organization` or `folder`.
  parent_id        = "12345678"
  billing_account  = "000-000-000"
  state_bucket     = "example-terraform-state"
  storage_location = "us-central1"
}

template "iam_members" {
  recipe_path = "{{$recipes}}/iam_members.hcl"
  output_path = "./iam_members"
  data = {
    iam_members = {
      "storage_bucket" = [
        {
          resource_ids = [
            "example-bucket",
          ]
          bindings = {
            "roles/storage.objectViewer" = [
              "serviceAccount:example-sa@example.iam.gserviceaccount.com",
              "group:example-group@example.com",
              "user:example-user@example.com"
            ]
            "roles/storage.objectCreator" = [
              "serviceAccount:example-sa@example.iam.gserviceaccount.com",
            ]
          }
        }
      ]
      "project" = [
        {
          resource_ids = [
            "example-project-one",
            "example-project-two",
          ]
          bindings = {
            "roles/compute.networkAdmin" = [
              "serviceAccount:example-sa@example.iam.gserviceaccount.com",
            ]
          }
        },
        {
          resource_ids = [
            "example-project-one"
          ]
          bindings = {
            "roles/compute.loadBalancerAdmin" = [
              "serviceAccount:example-sa@example.iam.gserviceaccount.com",
            ]
          }
        }
      ]
      "folder" = [
        {
          resource_ids = [
            "example-folder-one",
            "example-folder-two",
          ]
          bindings = {
            "roles/storage.objectViewer" = [
              "serviceAccount:example-sa@example.iam.gserviceaccount.com",
              "group:example-group@example.com",
              "user:example-user@example.com"
            ]
            "roles/storage.objectCreator" = [
              "serviceAccount:example-sa@example.iam.gserviceaccount.com",
            ]
          }
        }
      ]
    }
  }
}
