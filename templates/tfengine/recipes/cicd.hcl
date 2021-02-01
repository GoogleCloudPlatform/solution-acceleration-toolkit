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

schema = {
  title                = "CICD Recipe"
  additionalProperties = false
  required = [
    "envs",
    "terraform_root",
    "scheduler_region",
  ]
  properties = {
    project_id = {
      description = "ID of project to deploy CICD in."
      type        = "string"
      pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
    }
    github = {
      description          = "Config for GitHub Cloud Build triggers."
      type                 = "object"
      additionalProperties = false
      properties = {
        owner = {
          description = "GitHub repo owner."
          type        = "string"
        }
        name = {
          description = "GitHub repo name."
          type        = "string"
        }
      }
    }
    cloud_source_repository = {
      description          = "Config for Google Cloud Source Repository Cloud Build triggers."
      type                 = "object"
      additionalProperties = false
      required = [
        "name",
      ]
      properties = {
        name = {
          description = <<EOF
            Cloud Source Repository repo name.
            The Cloud Source Repository should be hosted under the devops project.
          EOF
          type        = "string"
        }
        readers = {
          description = <<EOF
            IAM members to allow reading the repo.
          EOF
          type        = "array"
          items = {
            type = "string"
          }
        }
        writers = {
          description = <<EOF
            IAM members to allow writing to the repo.
          EOF
          type        = "array"
          items = {
            type = "string"
          }
        }
      }
    }
    build_viewers = {
      description = <<EOF
        IAM members to grant `cloudbuild.builds.viewer` role in the devops project
        to see CICD results.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    build_editors = {
      description = <<EOF
        IAM members to grant `cloudbuild.builds.editor` role in the devops project
        to see CICD results.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    scheduler_region = {
      description = <<EOF
        [Region](https://cloud.google.com/appengine/docs/locations) where the scheduler
        job (or the App Engine App behind the sceneces) resides. Must be specified if
        any triggers are configured to be run on schedule.
      EOF
      type        = "string"
    }
    terraform_root = {
      description = <<EOF
        Path of the directory relative to the repo root containing the Terraform configs.
        Do not include ending "/".
      EOF
      type        = "string"
    }
    grant_automation_billing_user_role = {
      description = <<EOF
        Whether or not to grant automation service account the billing.user role.
        Default to true.
      EOF
      type        = "boolean"
    }
    envs = {
      description = <<EOF
        Config block for per-environment resources.
      EOF
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "name",
          "branch_name",
          "triggers",
        ]
        properties = {
          name = {
            description = <<EOF
            Name of the environment.
          EOF
            type        = "string"
          }
          branch_name = {
            description = <<EOF
            Name of the branch to set the Cloud Build Triggers to monitor.
            Regex is not supported to enforce a 1:1 mapping from a branch to a GCP
            environment.
          EOF
            type        = "string"
          }
          managed_dirs = {
            description = <<EOF
            List of root modules managed by the CICD relative to `terraform_root`.

            NOTE: The modules will be deployed in the given order. If a module
            depends on another module, it should show up after it in this list.

            NOTE: The CICD has permission to update APIs within its own project.
            Thus, you can list the devops module as one of the managed modules.
            Other changes to the devops project or CICD pipelines must be deployed
            manually.
          EOF
            type        = "array"
            items = {
              type = "string"
            }
          }
          triggers = {
            description          = <<EOF
            Config block for the CICD Cloud Build triggers.
          EOF
            type                 = "object"
            additionalProperties = false
            properties = {
              validate = {
                description          = <<EOF
                Config block for the presubmit validation Cloud Build trigger. If specified, create
                the trigger and grant the Cloud Build Service Account necessary permissions to
                perform the build.
              EOF
                type                 = "object"
                additionalProperties = false
                properties = {
                  run_on_push = {
                    description = <<EOF
                    Whether or not to be automatically triggered from a PR/push to branch.
                    Default to true.
                  EOF
                    type        = "boolean"
                  }
                  run_on_schedule = {
                    description = <<EOF
                    Whether or not to be automatically triggered according a specified schedule.
                    The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
                    at Eastern Standard Time (EST). Default to none.
                  EOF
                    type        = "string"
                  }
                }
              }
              plan = {
                description          = <<EOF
                Config block for the presubmit plan Cloud Build trigger.
                If specified, create the trigger and grant the Cloud Build Service Account
                necessary permissions to perform the build.
              EOF
                type                 = "object"
                additionalProperties = false
                properties = {
                  run_on_push = {
                    description = <<EOF
                    Whether or not to be automatically triggered from a PR/push to branch.
                    Default to true.
                  EOF
                    type        = "boolean"
                  }
                  run_on_schedule = {
                    description = <<EOF
                    Whether or not to be automatically triggered according a specified schedule.
                    The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
                    at Eastern Standard Time (EST). Default to none.
                  EOF
                    type        = "string"
                  }
                }
              }
              apply = {
                description          = <<EOF
                Config block for the postsubmit apply/deployyemt Cloud Build trigger.
                If specified,create the trigger and grant the Cloud Build Service Account
                necessary permissions to perform the build.
              EOF
                type                 = "object"
                additionalProperties = false
                properties = {
                  run_on_push = {
                    description = <<EOF
                    Whether or not to be automatically triggered from a PR/push to branch.
                    Default to true.
                  EOF
                    type        = "boolean"
                  }
                  run_on_schedule = {
                    description = <<EOF
                    Whether or not to be automatically triggered according a specified schedule.
                    The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
                    at Eastern Standard Time (EST). Default to none.
                  EOF
                    type        = "string"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

template "cicd" {
  component_path = "../components/cicd"
}
