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

data = {
  # Default locations for resources. Can be overridden in individual templates.
  storage_location    = "{{.default_location}}"
}

template "devops" {
  recipe_path = "{{.recipes}}/devops.hcl"
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to GCS.
    # enable_gcs_backend = true

    admins_group = {
      id     = "{{.prefix}}-team-admins@{{.domain}}"
      customer_id = "{{.customer_id}}"
      exists = false
    }

    project = {
      project_id = "{{.prefix}}-{{.env}}-devops"
      owners_group = {
        id     = "{{.prefix}}-devops-owners@{{.domain}}"
        customer_id = "{{.customer_id}}"
        exists = false
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
    terraform_addons = {
      providers = [
        {
          name = "google",
          version_constraints = ">=3.0, <= 3.71"
        },
        {
          name = "google-beta",
          version_constraints = "~>3.50"
        }
      ]
    }
  }
}

# Must first be deployed manually before 'cicd' is deployed because some groups created
# here are used in 'cicd' template.
template "groups" {
  recipe_path = "{{.recipes}}/project.hcl"
  output_path = "./groups"
  data = {
    project = {
      project_id = "{{.prefix}}-{{.env}}-devops"
      exists     = true
    }
    resources = {
      groups = [
        # Groups used in the CICD.
        {
          id          = "{{.prefix}}-cicd-viewers@{{.domain}}"
          customer_id = "c12345678"
        },
        {
          id          = "{{.prefix}}-cicd-editors@{{.domain}}"
          customer_id = "c12345678"
        },
        # Groups used in the applications.
        {
          id          = "{{.prefix}}-apps-viewers@{{.domain}}"
          customer_id = "c12345678"
          owners = [
            "user1@{{.domain}}"
          ]
        },
        {
          id          = "{{.prefix}}-data-viewers@{{.domain}}"
          customer_id = "c12345678"
          owners = [
            "user1@{{.domain}}"
          ]
        },
        {
          id          = "{{.prefix}}-healthcare-dataset-viewers@{{.domain}}"
          customer_id = "c12345678"
          owners = [
            "user1@{{.domain}}"
          ]
        },
        {
          id          = "{{.prefix}}-fhir-viewers@{{.domain}}"
          customer_id = "c12345678"
          owners = [
            "user1@{{.domain}}"
          ]
        },
        {
          id          = "{{.prefix}}-bastion-accessors@{{.domain}}"
          customer_id = "c12345678"
          owners = [
            "user1@{{.domain}}"
          ]
        },
      ]
    }
  }
}

template "cicd" {
  recipe_path = "{{.recipes}}/cicd.hcl"
  output_path = "./cicd"
  data = {
    project_id = "{{.prefix}}-{{.env}}-devops"
    github = {
      owner = "GoogleCloudPlatform"
      name  = "example"
    }

    # Required for scheduler.
    scheduler_region = "us-east1"

    build_viewers = ["group:{{.prefix}}-cicd-viewers@{{.domain}}"]
    build_editors = ["group:{{.prefix}}-cicd-editors@{{.domain}}"]

    terraform_root = "terraform"

    service_account = {
      id = "cloudbuild-sa"
    }
    logs_bucket = "{{.prefix}}-{{.env}}-devops-cloudbuild-logs-bucket"
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
          "project_secrets",
          "project_networks",
          "project_apps",
          "project_data",
          "additional_iam_members",
        ]
        worker_pool = {
          project  = "{{.prefix}}-{{.env}}-devops"
          location = "us-east1"
          name     = "cicd-pool"
        }
      }
    ]
    terraform_addons = {
      providers = [
        {
          name = "google",
          version_constraints = ">=3.0, <= 3.71"
        },
        {
          name = "google-beta",
          version_constraints = "~>3.50"
        }
      ]
    }
  }
}
