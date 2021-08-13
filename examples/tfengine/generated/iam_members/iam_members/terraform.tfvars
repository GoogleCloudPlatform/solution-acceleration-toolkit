# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


folder_iam_members = [
  {
    resource_ids = [
      "example-folder-one",
      "example-folder-two",
    ]
    bindings = {
      "roles/storage.objectCreator" = [
        "serviceAccount:example-sa@example.iam.gserviceaccount.com",
      ],
      "roles/storage.objectViewer" = [
        "serviceAccount:example-sa@example.iam.gserviceaccount.com",
        "group:example-group@example.com",
        "user:example-user@example.com",
      ],
    }
  },
]

project_iam_members = [
  {
    resource_ids = [
      "example-project-one",
      "example-project-two",
    ]
    bindings = {
      "roles/compute.networkAdmin" = [
        "serviceAccount:example-sa@example.iam.gserviceaccount.com",
      ],
    }
  },
  {
    resource_ids = ["example-project-one"]
    bindings = {
      "roles/compute.loadBalancerAdmin" = [
        "serviceAccount:example-sa@example.iam.gserviceaccount.com",
      ],
    }
  },
]

service_account_iam_members = [
  {
    resource_ids = ["example-sa@example.iam.gserviceaccount.com"]
    bindings = {
      "roles/iam.serviceAccountKeyAdmin" = [
        "serviceAccount:example-sa-two@example.iam.gserviceaccount.com",
        "group:example-group@example.com",
        "user:example-user@example.com",
      ],
    }
    project_id = "example"
  },
]

storage_bucket_iam_members = [
  {
    resource_ids = ["example-bucket"]
    bindings = {
      "roles/storage.objectCreator" = [
        "serviceAccount:example-sa@example.iam.gserviceaccount.com",
      ],
      "roles/storage.objectViewer" = [
        "serviceAccount:example-sa@example.iam.gserviceaccount.com",
        "group:example-group@example.com",
        "user:example-user@example.com",
      ],
    }
  },
]
