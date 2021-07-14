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
  source = "./validate"

  branch_name           = var.branch_name
  managed_dirs          = var.managed_dirs
  name                  = var.name
  skip                  = var.triggers.validate.skip
  run_on_push           = var.triggers.validate.run_on_push
  run_on_schedule       = var.triggers.validate.run_on_schedule
  github                = var.github
  project_id            = var.project_id
  scheduler_region      = var.scheduler_region
  terraform_root        = var.terraform_root
  terraform_root_prefix = var.terraform_root_prefix
}

module "plan_triggers" {
  source = "./plan"

  branch_name           = var.branch_name
  managed_dirs          = var.managed_dirs
  name                  = var.name
  skip                  = var.triggers.plan.skip
  run_on_push           = var.triggers.plan.run_on_push
  run_on_schedule       = var.triggers.plan.run_on_schedule
  github                = var.github
  project_id            = var.project_id
  scheduler_region      = var.scheduler_region
  terraform_root        = var.terraform_root
  terraform_root_prefix = var.terraform_root_prefix
}

module "apply_triggers" {
  source = "./apply"

  branch_name           = var.branch_name
  managed_dirs          = var.managed_dirs
  name                  = var.name
  skip                  = var.triggers.apply.skip
  run_on_push           = var.triggers.apply.run_on_push
  run_on_schedule       = var.triggers.apply.run_on_schedule
  github                = var.github
  project_id            = var.project_id
  scheduler_region      = var.scheduler_region
  terraform_root        = var.terraform_root
  terraform_root_prefix = var.terraform_root_prefix
}
