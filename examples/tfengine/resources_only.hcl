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
  parent_type     = "folder"
  parent_id       = "12345678"
  billing_account = "000-000-000"
  state_bucket    = "example-terraform-state"

  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location   = "us-east1"
  healthcare_location = "us-central1"
  storage_location    = "us-central1"

  labels = {
    env = "prod"
  }
}

# Resource deployment can be further splitted to group resources and share resource templates.

template "resources" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./resources"
  data = {
    project = {
      project_id = "example-prod-project"
      exists     = true
    }
    resources = {
      service_accounts = [{
        account_id   = "example-sa"
        description  = "Example Service Account"
        display_name = "Example Service Account"
      }]
      bigquery_datasets = [{
        # Override Terraform resource name as it cannot start with a number.
        resource_name               = "one_billion_ms_example_dataset"
        dataset_id                  = "1billion_ms_example_dataset"
        default_table_expiration_ms = 1e+9
        labels = {
          type = "phi"
        }
        access = [
          {
            role          = "roles/bigquery.dataOwner"
            special_group = "projectOwners"
          },
          {
            role           = "roles/bigquery.dataViewer"
            group_by_email = "example-data-viewers@example.com"
          },
        ]
      }]
      healthcare_datasets = [{
        name = "example-healthcare-dataset"
        iam_members = [{
          role   = "roles/healthcare.datasetViewer"
          member = "group:example-healthcare-dataset-viewers@example.com",
        }]
        dicom_stores = [{
          name = "example-dicom-store"
          labels = {
            type = "phi"
          }
        }]
        fhir_stores = [{
          name    = "example-fhir-store"
          version = "R4"
          labels = {
            type = "phi"
          }
          iam_members = [{
            role   = "roles/healthcare.fhirStoreViewer"
            member = "group:example-fhir-viewers@example.com",
          }]
        }]
        hl7_v2_stores = [{
          name = "example-hl7-store"
          labels = {
            type = "phi"
          }
        }]
      }]
      storage_buckets = [{
        name = "example-prod-bucket"
        force_destroy = false # For example purposes only
        labels = {
          type = "phi"
        }
        iam_members = [{
          role   = "roles/storage.objectViewer"
          member = "group:example-data-viewers@example.com"
        }]
      }]
    }
  }
}
