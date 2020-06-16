# Copyright 2020 Google LLC
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

# {{$base := "../../templates/tfengine/recipes"}}

data = {
  parent_type     = "organization"
  org_id          = "12345678"
  billing_account = "000-000-000"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location = "us-east1"
  cloud_sql_region  = "us-central1"
  compute_region    = "us-central1"
  storage_location  = "us-central1"
}

# Foundation for the org.
template "foundation" {
  recipe_path = "{{$base}}/org/foundation.hcl"
  data = {
    parent_type = "organization" # One of `organization` or `folder`.
    parent_id   = "12345678"

    devops = {
      project_id   = "example-devops"
      state_bucket = "example-terraform-state"
      org_admin    = "group:example-org-admin@example.com"
      project_owners = [
        "group:example-devops-owners@example.com",
      ]

      # TODO(user): Uncomment and re-run the engine after generated bootstrap module has been deployed.
      # Run `terraform init` in the bootstrap module to backup its state to GCS.
      # bootstrap_gcs_backend = true
    }

    audit = {
      project_id   = "example-audit"
      dataset_name = "1yr_org_audit_logs"
      bucket_name  = "7yr-org-audit-logs"
      auditors     = "group:example-dev-auditors@example.com",
    }

    monitor = {
      project_id = "example-monitor"
      domain     = "example.com"
    }

    org_policies = {
      allowed_policy_member_customer_ids = [
        "example_customer_id",
      ]
    }

    cicd = {
      project_id   = "example-devops"
      state_bucket = "example-state-bucket"
      github = {
        owner = "GoogleCloudPlatform"
        name  = "example"
      }
      branch_regex                  = "master"
      continuous_deployment_enabled = true
      trigger_enabled               = true
      build_viewers = [
        "group:example-cicd-viewers@example.com",
      ]
    }
  }
}
