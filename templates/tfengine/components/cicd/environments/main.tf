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
# limitations under the License.\

# ================== validate triggers ==================

module "validate_on_push" {
  source                  = "./trigger"

  filename                = "tf-validate.yaml"
  
  managed_dirs            = var.managed_dirs
  name                    = "tf-validate-${var.name}"
  description             = "Terraform validate job triggered on push event."
  skip                    = var.triggers.validate.skip
  run_on_push             = var.triggers.validate.run_on_push
  {{- if has . "cloud_source_repository"}}
  cloud_source_repository {
    name = var.cloud_source_repository.name
    branch_name = var.branch_name
  }
  {{- end}}
  {{- if has . "github"}}
  github                  = var.github
  pull_request {
    branch = var.branch_name
  }
  {{- end}}
  project_id              = var.project_id
  terraform_root          = var.terraform_root
  terraform_root_prefix   = var.terraform_root_prefix
}

module "validate_scheduled" {
  source                  = "./trigger"

  filename                = "tf-validate.yaml"
  
  branch_name             = var.branch_name
  managed_dirs            = var.managed_dirs
  name                    = "tf-validate-scheduled-${var.name}"
  description             = "Terraform validate job triggered on schedule."
  skip                    = (var.triggers.validate.skip || var.triggers.validate.run_on_schedule == "") 
  run_on_push             = false # Always disabled on push to branch.
  {{- if has . "cloud_source_repository"}}
  cloud_source_repository {
    name = var.cloud_source_repository.name
    branch_name = var.branch_name
  }
  {{- end}}
  {{- if has . "github"}}
  github                  = var.github
  push {
    branch = var.branch_name
  }
  {{- end}}
  project_id              = var.project_id
  terraform_root          = var.terraform_root
  terraform_root_prefix   = var.terraform_root_prefix
}

module "validate_scheduler" {
  source                  = "./scheduler"

  trigger_type            = "validate"
  
  skip                    = (var.triggers.validate.skip || var.triggers.validate.run_on_schedule == "") 
  project_id              = var.project_id
  name                    = "validate-scheduler-${var.name}"
  scheduler_region        = var.scheduler_region
  run_on_schedule         = var.triggers.validate.run_on_schedule
  branch_name             = var.branch_name
}

# ================== plan triggers ==================

module "plan_on_push" {
  source                  = "./trigger"

  filename                = "tf-plan.yaml"
  
  managed_dirs            = var.managed_dirs
  name                    = "tf-plan-${var.name}"
  description             = "Terraform plan job triggered on push event."
  skip                    = var.triggers.plan.skip
  run_on_push             = var.triggers.plan.run_on_push
  {{- if has . "cloud_source_repository"}}
  cloud_source_repository {
    name = var.cloud_source_repository.name
    branch_name = var.branch_name
  }
  {{- end}}
  {{- if has . "github"}}
  github                  = var.github
  pull_request {
    branch = var.branch_name
  }
  {{- end}}
  project_id              = var.project_id
  terraform_root          = var.terraform_root
  terraform_root_prefix   = var.terraform_root_prefix
}

module "plan_scheduled" {
  source                  = "./trigger"

  filename                = "tf-plan.yaml"
  
  branch_name             = var.branch_name
  managed_dirs            = var.managed_dirs
  name                    = "tf-plan-scheduled-${var.name}"
  description             = "Terraform plan job triggered on schedule."
  skip                    = (var.triggers.plan.skip || var.triggers.plan.run_on_schedule == "") 
  run_on_push             = false # Always disabled on push to branch.
  {{- if has . "cloud_source_repository"}}
  cloud_source_repository {
    name = var.cloud_source_repository.name
    branch_name = var.branch_name
  }
  {{- end}}
  {{- if has . "github"}}
  github                  = var.github
  push {
    branch = var.branch_name
  }
  {{- end}}
  project_id              = var.project_id
  terraform_root          = var.terraform_root
  terraform_root_prefix   = var.terraform_root_prefix
}

module "plan_scheduler" {
  source                  = "./scheduler"

  trigger_type            = "plan"
  
  skip                    = (var.triggers.plan.skip || var.triggers.plan.run_on_schedule == "") 
  project_id              = var.project_id
  name                    = "plan-scheduler-${var.name}"
  scheduler_region        = var.scheduler_region
  run_on_schedule         = var.triggers.plan.run_on_schedule
  branch_name             = var.branch_name
}

# ================== apply triggers ==================

module "apply_on_push_and_or_scheduled" {
  source                  = "./trigger"

  filename                = "tf-apply.yaml"
  
  branch_name             = var.branch_name
  managed_dirs            = var.managed_dirs
  name                    = "tf-apply-${var.name}"
  description             = "Terraform apply job triggered on push event and/or schedule."
  skip                    = var.triggers.apply.skip
  run_on_push             = var.triggers.apply.run_on_push
  {{- if has . "cloud_source_repository"}}
  cloud_source_repository {
    name = var.cloud_source_repository.name
    branch_name = var.branch_name
  }
  {{- end}}
  {{- if has . "github"}}
  github                  = var.github
  push {
    branch = var.branch_name
  }
  {{- end}}
  project_id              = var.project_id
  terraform_root          = var.terraform_root
  terraform_root_prefix   = var.terraform_root_prefix
}

module "apply_scheduler" {
  source                  = "./scheduler"

  trigger_type            = "apply"
  
  skip                    = (var.triggers.apply.skip || var.triggers.apply.run_on_schedule == "") 
  project_id              = var.project_id
  name                    = "apply-scheduler-${var.name}"
  scheduler_region        = var.scheduler_region
  run_on_schedule         = var.triggers.apply.run_on_schedule
  branch_name             = var.branch_name
}
