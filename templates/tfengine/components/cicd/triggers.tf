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

{{- $terraform_root := .terraform_root}}
{{- if eq $terraform_root "/"}}
  {{- $terraform_root = "."}}
{{- end}}


{{- $terraform_root_prefix := printf "%s/" $terraform_root}}
{{- if eq $terraform_root "."}}
  {{- $terraform_root_prefix = ""}}
{{- end}}

{{- $worker_pool := ""}}
{{- if has . "worker_pool"}}
  {{- $worker_pool := printf "projects/%s/locations/%s/workerPools/%s" .worker_pool.project .worker_pool.location .worker_pool.name}}
{{- end}}

{{range get . "envs" -}}
# ================== Triggers for "{{.name}}" environment ==================
{{- $managed_dirs := ""}}
{{- range .managed_dirs}}
{{- $managed_dirs = trimSpace (printf "%s %s" $managed_dirs .)}}
{{- end}}

{{- if has .triggers "validate"}}

resource "google_cloudbuild_trigger" "validate_{{.name}}" {
  {{- if not (get .triggers.validate "run_on_push" true)}}
  disabled    = true
  {{- end}}
  project     = var.project_id
  name        = "tf-validate-{{.name}}"
  description = "Terraform validate job triggered on push event."

  included_files = [
    "{{$terraform_root_prefix}}**",
  ]

  {{if has $ "github" -}}
  github {
    owner = "{{$.github.owner}}"
    name  = "{{$.github.name}}"
    pull_request {
      branch = "^{{.branch_name}}$"
    }
  }
  {{- else if has $ "cloud_source_repository" -}}
  trigger_template {
    repo_name   = "{{$.cloud_source_repository.name}}"
    branch_name = "^{{.branch_name}}$"
  }
  {{- end}}

  filename = "{{$terraform_root_prefix}}cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "{{$terraform_root}}"
    _MANAGED_DIRS = "{{$managed_dirs}}"
    _WORKER_POOL = "{{$worker_pool}}"
  }

  depends_on = [
    google_project_service.services,
{{- if has $ "cloud_source_repository"}}
    google_sourcerepo_repository.configs,
{{- end}}
  ]
}

{{- if has .triggers.validate "run_on_schedule"}}

# Create another trigger as Pull Request Cloud Build triggers cannot be used by Cloud Scheduler.
resource "google_cloudbuild_trigger" "validate_scheduled_{{.name}}" {
  # Always disabled on push to branch.
  disabled    = true
  project     = var.project_id
  name        = "tf-validate-scheduled-{{.name}}"
  description = "Terraform validate job triggered on schedule."

  included_files = [
    "{{$terraform_root_prefix}}**",
  ]

  {{if has $ "github" -}}
  github {
    owner = "{{$.github.owner}}"
    name  = "{{$.github.name}}"
    push {
      branch = "^{{.branch_name}}$"
    }
  }
  {{- else if has $ "cloud_source_repository" -}}
  trigger_template {
    repo_name   = "{{$.cloud_source_repository.name}}"
    branch_name = "^{{.branch_name}}$"
  }
  {{- end}}

  filename = "{{$terraform_root_prefix}}cicd/configs/tf-validate.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "{{$terraform_root}}"
    _MANAGED_DIRS = "{{$managed_dirs}}"
  }

  depends_on = [
    google_project_service.services,
{{- if has $ "cloud_source_repository"}}
    google_sourcerepo_repository.configs,
{{- end}}
  ]
}

resource "google_cloud_scheduler_job" "validate_scheduler_{{.name}}" {
  project   = var.project_id
  name      = "validate-scheduler-{{.name}}"
  region    = "{{$.scheduler_region}}"
  schedule  = "{{.triggers.validate.run_on_schedule}}"
  time_zone = "America/New_York" # Eastern Standard Time (EST)
  attempt_deadline = "60s"
  http_target {
    http_method = "POST"
    oauth_token {
      scope = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = "${google_service_account.cloudbuild_scheduler_sa.email}"
    }
    uri = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.validate_scheduled_{{.name}}.id}:run"
    body = base64encode("{\"branchName\":\"{{.branch_name}}\"}")
  }
  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
  ]
}
{{- end}}
{{- end}}

{{- if has .triggers "plan"}}

resource "google_cloudbuild_trigger" "plan_{{.name}}" {
  {{- if not (get .triggers.plan "run_on_push" true)}}
  disabled    = true
  {{- end}}
  project     = var.project_id
  name        = "tf-plan-{{.name}}"
  description = "Terraform plan job triggered on push event."

  included_files = [
    "{{$terraform_root_prefix}}**",
  ]

  {{if has $ "github" -}}
  github {
    owner = "{{$.github.owner}}"
    name  = "{{$.github.name}}"
    pull_request {
      branch = "^{{.branch_name}}$"
    }
  }
  {{- else if has $ "cloud_source_repository" -}}
  trigger_template {
    repo_name   = "{{$.cloud_source_repository.name}}"
    branch_name = "^{{.branch_name}}$"
  }
  {{- end}}

  filename = "{{$terraform_root_prefix}}cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "{{$terraform_root}}"
    _MANAGED_DIRS = "{{$managed_dirs}}"
  }

  depends_on = [
    google_project_service.services,
{{- if has $ "cloud_source_repository"}}
    google_sourcerepo_repository.configs,
{{- end}}
  ]
}

{{- if has .triggers.plan "run_on_schedule"}}

# Create another trigger as Pull Request Cloud Build triggers cannot be used by Cloud Scheduler.
resource "google_cloudbuild_trigger" "plan_scheduled_{{.name}}" {
  # Always disabled on push to branch.
  disabled    = true
  project     = var.project_id
  name        = "tf-plan-scheduled-{{.name}}"
  description = "Terraform plan job triggered on schedule."

  included_files = [
    "{{$terraform_root_prefix}}**",
  ]

  {{if has $ "github" -}}
  github {
    owner = "{{$.github.owner}}"
    name  = "{{$.github.name}}"
    push {
      branch = "^{{.branch_name}}$"
    }
  }
  {{- else if has $ "cloud_source_repository" -}}
  trigger_template {
    repo_name   = "{{$.cloud_source_repository.name}}"
    branch_name = "^{{.branch_name}}$"
  }
  {{- end}}

  filename = "{{$terraform_root_prefix}}cicd/configs/tf-plan.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "{{$terraform_root}}"
    _MANAGED_DIRS = "{{$managed_dirs}}"
  }

  depends_on = [
    google_project_service.services,
{{- if has $ "cloud_source_repository"}}
    google_sourcerepo_repository.configs,
{{- end}}
  ]
}

resource "google_cloud_scheduler_job" "plan_scheduler_{{.name}}" {
  project   = var.project_id
  name      = "plan-scheduler-{{.name}}"
  region    = "{{$.scheduler_region}}"
  schedule  = "{{.triggers.plan.run_on_schedule}}"
  time_zone = "America/New_York" # Eastern Standard Time (EST)
  attempt_deadline = "60s"
  http_target {
    http_method = "POST"
    oauth_token {
      scope = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = "${google_service_account.cloudbuild_scheduler_sa.email}"
    }
    uri = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.plan_scheduled_{{.name}}.id}:run"
    body = base64encode("{\"branchName\":\"{{.branch_name}}\"}")
  }
  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
  ]
}
{{- end}}
{{- end}}

{{- if has .triggers "apply"}}

resource "google_cloudbuild_trigger" "apply_{{.name}}" {
  {{- if not (get .triggers.apply "run_on_push" true)}}
  disabled    = true
  {{- end}}
  project     = var.project_id
  name        = "tf-apply-{{.name}}"
  description = "Terraform apply job triggered on push event and/or schedule."

  included_files = [
    "{{$terraform_root_prefix}}**",
  ]

  {{if has $ "github" -}}
  github {
    owner = "{{$.github.owner}}"
    name  = "{{$.github.name}}"
    push {
      branch = "^{{.branch_name}}$"
    }
  }
  {{- else if has $ "cloud_source_repository" -}}
  trigger_template {
    repo_name   = "{{$.cloud_source_repository.name}}"
    branch_name = "^{{.branch_name}}$"
  }
  {{- end}}

  filename = "{{$terraform_root_prefix}}cicd/configs/tf-apply.yaml"

  substitutions = {
    _TERRAFORM_ROOT = "{{$terraform_root}}"
    _MANAGED_DIRS = "{{$managed_dirs}}"
  }

  depends_on = [
    google_project_service.services,
{{- if has $ "cloud_source_repository"}}
    google_sourcerepo_repository.configs,
{{- end}}
  ]
}

{{- if has .triggers.apply "run_on_schedule"}}

resource "google_cloud_scheduler_job" "apply_scheduler_{{.name}}" {
  project   = var.project_id
  name      = "apply-scheduler-{{.name}}"
  region    = "{{$.scheduler_region}}"
  schedule  = "{{.triggers.apply.run_on_schedule}}"
  time_zone = "America/New_York" # Eastern Standard Time (EST)
  attempt_deadline = "60s"
  http_target {
    http_method = "POST"
    oauth_token {
      scope = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = "${google_service_account.cloudbuild_scheduler_sa.email}"
    }
    uri = "https://cloudbuild.googleapis.com/v1/${google_cloudbuild_trigger.apply_{{.name}}.id}:run"
    body = base64encode("{\"branchName\":\"{{.branch_name}}\"}")
  }
  depends_on = [
    google_project_service.services,
    google_app_engine_application.cloudbuild_scheduler_app,
  ]
}
{{- end}}
{{- end}}

{{end}}
