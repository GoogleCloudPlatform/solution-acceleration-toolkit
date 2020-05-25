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

{{$base := "../../templates/tfengine/recipes"}}

data = {
  org_id          = "12345678"
  billing_account = "000-000-000"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location = "us-east1"
  cloud_sql_region  = "us-central1"
  compute_region    = "us-central1"
  storage_location  = "us-central1"


  # TODO(user): This block prevents certain parts of the configs from being
  # generated which require dependencies to be deployed first.
  # Follow the steps listed for each field in the block, then remove this block
  # once nothing needs to be disabled.
  disabled = {
    # The bootstrap module creates the Terraform state bucket and thus
    # its own state cannot be backed up until the state bucket has been created.
    #
    # 1. Deploy the bootstrap module (deployed by the foundation recipe).
    #    The state will be created locally in the same directory.
    # 2. Remove this field and re-run the engine.
    # 3. In the bootstrap module run `terraform init` to backup the bootstrap state to GCS.
    bootstrap_gcs_backend = true
  }
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

    org_policies = {}

    cicd = {
      project_id                    = "example-devops"
      state_bucket                  = "example-state-bucket"
      repo_owner                    = "GoogleCloudPlatform"
      repo_name                     = "example"
      branch_regex                  = "master"
      continuous_deployment_enabled = true
      trigger_enabled               = true
      build_viewers = [
       "group:example-cicd-viewers@example.com",
      ]
    }
  }
}
