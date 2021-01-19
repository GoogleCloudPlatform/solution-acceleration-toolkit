# Copyright 2020 Google LLC
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
  cloud_sql_region    = "us-central1"
  cloud_sql_zone      = "a"
  compute_region      = "us-central1"
  compute_zone        = "a"
  gke_region          = "us-central1"
  healthcare_location = "us-central1"
  storage_location    = "us-central1"
  secret_locations    = ["us-central1"]

  labels = {
    env = "prod"
  }
}

template "devops" {
  recipe_path = "{{$recipes}}/devops.hcl"
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to GCS.
    # enable_gcs_backend = true

    admins_group = {
      id = "example-team-admins@example.com"
      exists = true
    }

    project = {
      project_id = "example-devops"
      owners_group = {
        id = "example-devops-owners@example.com"
        exists = true
      }
      apis = [
        "container.googleapis.com",
        "dns.googleapis.com",
        "healthcare.googleapis.com",
        "iap.googleapis.com",
        "pubsub.googleapis.com",
        "secretmanager.googleapis.com",
      ]
    }
  }
}

# Must first be deployed manually before 'cicd' is deployed because some groups created
# here are used in 'cicd' template.
template "groups" {
  recipe_path = "{{$recipes}}/project.hcl"
  output_path = "./groups"
  data = {
    project = {
      project_id = "example-devops"
      exists     = true
    }
    resources = {
      groups = [
        # Groups used in the CICD.
        {
          id = "example-cicd-viewers@example.com"
          customer_id = "c12345678"
        },
        {
          id = "example-cicd-editors@example.com"
          customer_id = "c12345678"
        },
        # Groups used in the applications.
        {
          id = "example-apps-viewers@example.com"
          customer_id = "c12345678"
          owners = [
            "user1@example.com"
          ]
        },
        {
          id = "example-data-viewers@example.com"
          customer_id = "c12345678"
          owners = [
            "user1@example.com"
          ]
        },
        {
          id = "example-healthcare-dataset-viewers@example.com"
          customer_id = "c12345678"
          owners = [
            "user1@example.com"
          ]
        },
        {
          id = "example-fhir-viewers@example.com"
          customer_id = "c12345678"
          owners = [
            "user1@example.com"
          ]
        },
        {
          id = "bastion-accessors@example.com"
          customer_id = "c12345678"
          owners = [
            "user1@example.com"
          ]
        },
      ]
    }
  }
}

template "cicd" {
  recipe_path = "{{$recipes}}/cicd.hcl"
  output_path = "./cicd"
  data = {
    project_id = "example-devops"
    github = {
      owner = "GoogleCloudPlatform"
      name  = "example"
    }

    # Required for scheduler.
    scheduler_region = "us-east1"

    build_viewers  = ["group:example-cicd-viewers@example.com"]
    build_editors  = ["group:example-cicd-editors@example.com"]

    terraform_root = "terraform"
    envs = [
      {
        name        = "prod"
        branch_name = "main"
        # Prepare and enable default triggers.
        triggers = {
          validate = {}
          plan     = {}
          apply    = { run_on_push = false } # Do not auto run on push to branch
        }
        # Kubernetes intentionally left out as it cannot be deployed by CICD.
        managed_dirs = [
          "devops", // NOTE: CICD service account can only update APIs on the devops project.
          "project_secrets",
          "project_networks",
          "project_data",
          "project_apps",
        ]
      }
    ]
  }
}

template "main" {
	recipe_path = "./templates/team.hcl"
	data = {
		prefix = "example"
	}
}
