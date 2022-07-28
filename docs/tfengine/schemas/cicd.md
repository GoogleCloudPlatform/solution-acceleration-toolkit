# CICD Recipe

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| build_editors | IAM members to grant `cloudbuild.builds.editor` role in the devops project to see CICD results. | array(string) | false | - | - |
| build_viewers | IAM members to grant `cloudbuild.builds.viewer` role in the devops project to see CICD results. | array(string) | false | - | - |
| cloud_source_repository | Config for Google Cloud Source Repository.<br><br>IMPORTANT: Cloud Source Repositories does not support code review or presubmit runs. If you set both plan and apply to run at the same time, they will conflict and may error out. To get around this, for 'shared' and 'prod' environment, set 'apply' trigger to not 'run_on_push', and for other environments, do not specify the 'plan' trigger block and let 'apply' trigger 'run_on_push'. | object | false | - | - |
| cloud_source_repository.name | Cloud Source Repository repo name. The Cloud Source Repository should be hosted under the devops project. | string | true | - | - |
| cloud_source_repository.readers | IAM members to allow reading the repo. | array(string) | false | - | - |
| cloud_source_repository.writers | IAM members to allow writing to the repo. | array(string) | false | - | - |
| envs | Config block for per-environment resources. | array(object) | true | - | - |
| envs.branch_name | Name of the branch to set the Cloud Build Triggers to monitor. Regex is not supported to enforce a 1:1 mapping from a branch to a GCP environment. | string | true | - | - |
| envs.managed_dirs | List of root modules managed by the CICD relative to `terraform_root`.<br><br>NOTE: The modules will be deployed in the given order. If a module depends on another module, it should show up after it in this list.<br><br>NOTE: The CICD has permission to update APIs within its own project. Thus, you can list the devops module as one of the managed modules. Other changes to the devops project or CICD pipelines must be deployed manually. | array(string) | false | - | - |
| envs.name | Name of the environment. | string | true | - | - |
| envs.triggers | Config block for the CICD Cloud Build triggers. | object | true | - | - |
| envs.triggers.apply | Config block for the postsubmit apply/deployyemt Cloud Build trigger. If specified,create the trigger and grant the Cloud Build Service Account necessary permissions to perform the build. | object | false | - | - |
| envs.triggers.apply.run_on_push | Whether or not to be automatically triggered from a PR/push to branch. Default to true. | boolean | false | - | - |
| envs.triggers.apply.run_on_schedule | Whether or not to be automatically triggered according a specified schedule. The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule) at Eastern Standard Time (EST). Default to none. | string | false | - | - |
| envs.triggers.plan | Config block for the presubmit plan Cloud Build trigger. If specified, create the trigger and grant the Cloud Build Service Account necessary permissions to perform the build. | object | false | - | - |
| envs.triggers.plan.run_on_push | Whether or not to be automatically triggered from a PR/push to branch. Default to true. | boolean | false | - | - |
| envs.triggers.plan.run_on_schedule | Whether or not to be automatically triggered according a specified schedule. The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule) at Eastern Standard Time (EST). Default to none. | string | false | - | - |
| envs.triggers.validate | Config block for the presubmit validation Cloud Build trigger. If specified, create the trigger and grant the Cloud Build Service Account necessary permissions to perform the build. | object | false | - | - |
| envs.triggers.validate.run_on_push | Whether or not to be automatically triggered from a PR/push to branch. Default to true. | boolean | false | - | - |
| envs.triggers.validate.run_on_schedule | Whether or not to be automatically triggered according a specified schedule. The schedule is specified using [unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule) at Eastern Standard Time (EST). Default to none. | string | false | - | - |
| envs.worker_pool | Optional Cloud Build private worker pool configuration. Required for CICD to access resources in a private network, e.g. GKE clusters with a private endpoint. | object | false | - | - |
| envs.worker_pool.location | GCP region of the worker pool. Example: us-central1. | string | true | - | - |
| envs.worker_pool.name | Name of the worker pool. | string | true | - | - |
| envs.worker_pool.project | The project worker pool belongs. | string | true | - | - |
| github | Config for GitHub Cloud Build triggers. | object | false | - | - |
| github.name | GitHub repo name. | string | false | - | - |
| github.owner | GitHub repo owner. | string | false | - | - |
| grant_automation_billing_user_role | Whether or not to grant automation service account the billing.user role. Default to true. | boolean | false | - | - |
| logs_bucket | Name of the Google Cloud Storage bucket where Cloud Build logs should be written. The bucket will be created as part of CICD. | string | true | - | - |
| project_id | ID of project to deploy CICD in. | string | false | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| scheduler_region | [Region](https://cloud.google.com/sdk/gcloud/reference/scheduler/locations/list) where the scheduler job resides. Must be specified if any triggers are configured to be run on schedule. | string | true | - | - |
| service_account | The custom service account to run Cloud Build triggers. During the CICD deployment, this service account will be granted all necessary permissions to provision and manage your infrastructure. See <https://cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts#permissions> for more details. | object | true | - | - |
| service_account.exists | Whether the service account exists. Defaults to 'false'. | boolean | false | - | - |
| service_account.id | ID of the service account. | string | true | - | - |
| storage_location | Location of logs bucket. | string | false | - | - |
| terraform_addons | Additional Terraform configuration for the cicd deployment. For schema see ./deployment.hcl. | - | false | - | - |
| terraform_root | Path of the directory relative to the repo root containing the Terraform configs. Do not include ending "/". | string | true | - | - |
