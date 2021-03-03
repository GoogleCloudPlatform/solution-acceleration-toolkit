# CICD Recipe

<!-- These files are auto generated -->

## Properties

### build_editors

IAM members to grant `cloudbuild.builds.editor` role in the devops project
to see CICD results.

Type: array(string)

### build_viewers

IAM members to grant `cloudbuild.builds.viewer` role in the devops project
to see CICD results.

Type: array(string)

### cloud_source_repository

Config for Google Cloud Source Repository.

IMPORTANT: Cloud Source Repositories does not support code review or
presubmit runs. If you set both plan and apply to run at the same time,
they will conflict and may error out. To get around this, you should
only auto-apply for non-prod envs, and only plan for the prod env.

Type: object

### cloud_source_repository.name

Cloud Source Repository repo name.
The Cloud Source Repository should be hosted under the devops project.

Type: string

### cloud_source_repository.readers

IAM members to allow reading the repo.

Type: array(string)

### cloud_source_repository.writers

IAM members to allow writing to the repo.

Type: array(string)

### envs

Config block for per-environment resources.

Type: array(object)

### envs.branch_name

Name of the branch to set the Cloud Build Triggers to monitor.
Regex is not supported to enforce a 1:1 mapping from a branch to a GCP
environment.

Type: string

### envs.managed_dirs

List of root modules managed by the CICD relative to `terraform_root`.

NOTE: The modules will be deployed in the given order. If a module
depends on another module, it should show up after it in this list.

NOTE: The CICD has permission to update APIs within its own project.
Thus, you can list the devops module as one of the managed modules.
Other changes to the devops project or CICD pipelines must be deployed
manually.

Type: array(string)

### envs.name

Name of the environment.

Type: string

### envs.triggers

Config block for the CICD Cloud Build triggers.

Type: object

### envs.triggers.apply

Config block for the postsubmit apply/deployyemt Cloud Build trigger.
If specified,create the trigger and grant the Cloud Build Service Account
necessary permissions to perform the build.

Type: object

### envs.triggers.apply.run_on_push

Whether or not to be automatically triggered from a PR/push to branch.
Default to true.

Type: boolean

### envs.triggers.apply.run_on_schedule

Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.

Type: string

### envs.triggers.plan

Config block for the presubmit plan Cloud Build trigger.
If specified, create the trigger and grant the Cloud Build Service Account
necessary permissions to perform the build.

Type: object

### envs.triggers.plan.run_on_push

Whether or not to be automatically triggered from a PR/push to branch.
Default to true.

Type: boolean

### envs.triggers.plan.run_on_schedule

Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.

Type: string

### envs.triggers.validate

Config block for the presubmit validation Cloud Build trigger. If specified, create
the trigger and grant the Cloud Build Service Account necessary permissions to
perform the build.

Type: object

### envs.triggers.validate.run_on_push

Whether or not to be automatically triggered from a PR/push to branch.
Default to true.

Type: boolean

### envs.triggers.validate.run_on_schedule

Whether or not to be automatically triggered according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.

Type: string

### github

Config for GitHub Cloud Build triggers.

Type: object

### github.name

GitHub repo name.

Type: string

### github.owner

GitHub repo owner.

Type: string

### grant_automation_billing_user_role

Whether or not to grant automation service account the billing.user role.
Default to true.

Type: boolean

### project_id

ID of project to deploy CICD in.

Type: string

### scheduler_region

[Region](https://cloud.google.com/appengine/docs/locations) where the scheduler
job (or the App Engine App behind the sceneces) resides. Must be specified if
any triggers are configured to be run on schedule.

Type: string

### terraform_root

Path of the directory relative to the repo root containing the Terraform configs.
Do not include ending "/".

Type: string
