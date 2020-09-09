# CICD Recipe

<!-- These files are auto generated -->

## Properties

### branch_name

Name of the branch to set the Cloud Build Triggers to monitor.
Regex is not supported to enforce a 1:1 mapping from a branch to a GCP
environment.

Type: string

### build_viewers

IAM members to grant `cloudbuild.builds.viewer` role in the devops project
to see CICD results.

Type: array(string)

### cloud_source_repository

Config for Google Cloud Source Repository Cloud Build triggers.

Type: object

### cloud_source_repository.name

Cloud Source Repository repo name.
The Cloud Source Repository should be hosted under the devops project.

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

### managed_dirs

List of root modules managed by the CICD relative to `terraform_root`.

NOTE: The modules will be deployed in the given order. If a module
depends on another module, it should show up after it in this list.

NOTE: The CICD has permission to update APIs within its own project.
Thus, you can list the devops module as one of the managed modules.
Other changes to the devops project or CICD pipelines must be deployed
manually.

Type: array(string)

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

Type: string

### triggers

Config block for the CICD Cloud Build triggers.

Type: object

### triggers.apply

Config block for the postsubmit apply/deployyemt Cloud Build trigger.
If specified,create the trigger and grant the Cloud Build Service Account
necessary permissions to perform the build.

Type: object

### triggers.apply.run_on_push

Whether or not automatic triggering from a PR/push to branch. Default to true.

Type: boolean

### triggers.apply.run_on_schedule

Whether or not automatic triggering according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.

Type: string

### triggers.plan

Config block for the presubmit plan Cloud Build trigger.
If specified, create the trigger and grant the Cloud Build Service Account
necessary permissions to perform the build.

Type: object

### triggers.plan.run_on_push

Whether or not automatic triggering from a PR/push to branch. Default to true.

Type: boolean

### triggers.plan.run_on_schedule

Whether or not automatic triggering according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.

Type: string

### triggers.validate

Config block for the presubmit validation Cloud Build trigger. If specified, create
the trigger and grant the Cloud Build Service Account necessary permissions to
perform the build.

Type: object

### triggers.validate.run_on_push

Whether or not automatic triggering from a PR/push to branch. Default to true.

Type: boolean

### triggers.validate.run_on_schedule

Whether or not automatic triggering according a specified schedule.
The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule)
at Eastern Standard Time (EST). Default to none.

Type: string
