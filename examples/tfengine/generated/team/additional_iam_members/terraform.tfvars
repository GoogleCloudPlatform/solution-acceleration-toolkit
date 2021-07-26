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


project_iam_members = [
  {
    resource_ids = ["example-prod-data"]
    bindings = {
      "roles/browser" = [
        "serviceAccount:runner@example-prod-apps.iam.gserviceaccount.com",
      ],
    }
  },
]

service_account_iam_members = [
  {
    resource_ids = ["runner@example-prod-apps.iam.gserviceaccount.com"]
    bindings = {
      "roles/iam.serviceAccountKeyAdmin" = [
        "group:example-team-admins@example.com",
      ],
    }
    project_id = "example-prod-apps"
  },
]

storage_bucket_iam_members = [
  {
    resource_ids = ["example-bucket"]
    bindings = {
      "roles/storage.admin" = [
        "serviceAccount:runner@example-prod-apps.iam.gserviceaccount.com",
      ],
    }
  },
]
