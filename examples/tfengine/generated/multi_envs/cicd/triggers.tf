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

# ================== Triggers for "shared" environment ==================

resource "google_cloudbuild_trigger" "validate_shared" {
  project     = var.project_id
  name        = "tf-validate-shared"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^shared$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "groups audit folders"
    _WORKER_POOL    = ""
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

resource "google_cloudbuild_trigger" "plan_shared" {
  project     = var.project_id
  name        = "tf-plan-shared"
  description = "Terraform plan job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^shared$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "groups audit folders"
    _WORKER_POOL    = ""
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

resource "google_cloudbuild_trigger" "apply_shared" {
  disabled    = true
  project     = var.project_id
  name        = "tf-apply-shared"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^shared$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-apply.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "groups audit folders"
    _WORKER_POOL    = ""
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

# ================== Triggers for "dev" environment ==================

resource "google_cloudbuild_trigger" "validate_dev" {
  project     = var.project_id
  name        = "tf-validate-dev"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^dev$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "dev/data"
    _WORKER_POOL    = "projects/example-devops/locations/us-east1/workerPools/cicd-pool-one"
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

resource "google_cloudbuild_trigger" "apply_dev" {
  project     = var.project_id
  name        = "tf-apply-dev"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^dev$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-apply.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "dev/data"
    _WORKER_POOL    = "projects/example-devops/locations/us-east1/workerPools/cicd-pool-one"
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

# ================== Triggers for "prod" environment ==================

resource "google_cloudbuild_trigger" "validate_prod" {
  project     = var.project_id
  name        = "tf-validate-prod"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^main$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "prod/data"
    _WORKER_POOL    = "projects/example-devops/locations/us-east1/workerPools/cicd-pool-two"
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

resource "google_cloudbuild_trigger" "plan_prod" {
  project     = var.project_id
  name        = "tf-plan-prod"
  description = "Terraform plan job triggered on push event."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^main$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "prod/data"
    _WORKER_POOL    = "projects/example-devops/locations/us-east1/workerPools/cicd-pool-two"
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}

resource "google_cloudbuild_trigger" "apply_prod" {
  disabled    = true
  project     = var.project_id
  name        = "tf-apply-prod"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "terraform/**",
  ]

  trigger_template {
    repo_name   = "example"
    branch_name = "^main$"
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.cloudbuild_sa_email}"

  filename = "terraform/cicd/configs/tf-apply.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "terraform"
    _MANAGED_DIRS   = "prod/data"
    _WORKER_POOL    = "projects/example-devops/locations/us-east1/workerPools/cicd-pool-two"
    _LOGS_BUCKET    = "gs://${module.logs_bucket.name}"
  }

  depends_on = [
    google_project_service.services,
    google_sourcerepo_repository.configs,
  ]
}


