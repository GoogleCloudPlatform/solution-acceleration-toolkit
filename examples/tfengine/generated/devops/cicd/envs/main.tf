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

module "validate_triggers" {
  source = "./triggers"

  command                 = "validate"
  env                     = var.env
  branch_name             = var.branch_name
  managed_dirs            = var.managed_dirs
  run_on_schedule         = var.triggers.validate.run_on_schedule
  cloud_source_repository = var.cloud_source_repository
  github                  = var.github
  project_id              = var.project_id
  scheduler_region        = var.scheduler_region
  terraform_root          = var.terraform_root
  service_account_email   = var.service_account_email

  push = {
    skip     = var.triggers.validate.skip
    disabled = !var.triggers.validate.run_on_push
  }

  scheduled = {
    skip     = var.triggers.validate.skip || var.triggers.validate.run_on_schedule == ""
    disabled = true # Always disabled on push to branch.
  }
}

module "plan_triggers" {
  source = "./triggers"

  command                 = "plan"
  env                     = var.env
  branch_name             = var.branch_name
  managed_dirs            = var.managed_dirs
  run_on_schedule         = var.triggers.plan.run_on_schedule
  cloud_source_repository = var.cloud_source_repository
  github                  = var.github
  project_id              = var.project_id
  scheduler_region        = var.scheduler_region
  terraform_root          = var.terraform_root
  service_account_email   = var.service_account_email

  push = {
    skip     = var.triggers.plan.skip
    disabled = !var.triggers.plan.run_on_push
  }

  scheduled = {
    skip     = var.triggers.plan.skip || var.triggers.plan.run_on_schedule == ""
    disabled = true # Always disabled on push to branch.
  }
}

module "apply_triggers" {
  source = "./triggers"

  command                 = "apply"
  env                     = var.env
  branch_name             = var.branch_name
  managed_dirs            = var.managed_dirs
  run_on_schedule         = var.triggers.apply.run_on_schedule
  cloud_source_repository = var.cloud_source_repository
  github                  = var.github
  project_id              = var.project_id
  scheduler_region        = var.scheduler_region
  terraform_root          = var.terraform_root
  service_account_email   = var.service_account_email

  push = {
    skip     = true # Always true since scheduled trigger may act as a push trigger too
    disabled = true
  }

  scheduled = {
    skip     = var.triggers.apply.skip
    disabled = !var.triggers.apply.run_on_push
  }
}
