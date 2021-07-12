# Continuous integration (CI) and continuous deployment (CD)

This directory defines the resources that need to be deployed manually to set up
CICD pipelines of Terraform configs.

The CI and CD pipelines use
[Google Cloud Build](https://cloud.google.com/cloud-build) and
[Cloud Build triggers](https://cloud.google.com/cloud-build/docs/automating-builds/create-manage-triggers)
to detect changes in the repo, trigger builds, and run the workloads.

## Setup

1. Generate the CICD Terraform configs and Cloud Build configs using the
    Terraform Engine. Only the Terraform resources in the current directory,
    that is, the `cicd/` directory under root, need to be deployed manually.

1. If your VCS is GitHub, first install the Cloud Build app and
    [connect your GitHub repository](https://console.cloud.google.com/cloud-build/triggers/connect)
    to your Cloud project by following the steps in
    [Installing the Cloud Build app](https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app).
    To perform this operation, you need Admin permission in that GitHub
    repository. This can't be done through automation.

    If your VCS is Cloud Source Repository (CSR), proceed directly to the next
    step.

1. Run the following commands in this directory to enable the necessary APIs,
    grant the Cloud Build service account the necessary permissions, and create
    Cloud Build triggers:

    ```shell
    terraform init
    terraform apply
    ```

1. In addition, if you would like to enable CICD to manage groups and
    memberships for you:

    1. Make sure output directories which contain the groups resources are
        included in the `managed_dirs` list in the `cicd` template.
    1. Grant **Google Workspace Group Editor** role to the CICD service account
        `<devops-project-number>@cloudbuild.gserviceaccount.com` by following
        the following steps:

        1. Go to Google Admin console's Admin roles configuration page
            <https://admin.google.com/u/1/ac/roles>
        1. Click `Groups Editor`;
        1. Click `Admins assigned`;
        1. Click `Assign service accounts` and input the CICD service account
            email address.

    Alternatively, follow steps
    [here](https://cloud.google.com/identity/docs/how-to/setup#assigning_an_admin_role_to_the_service_account).

    In either approach, you must be a **Google Workspace Super Admin** to be
    able to complete those steps.

## CICD Container

The Docker container used for CICD executions are built and maintained by the
Cloud Foundation Toolkit (CFT) team. Documentations and scripts can be found
[here](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/tree/master/infra/build/developer-tools-light).
This container includes necessary dependencies (e.g. bash, terraform, gcloud) to
validate and deploy Terraform configs. If you would like to use a different
container for production deployment, you can modify the Cloud Build YAML files
in [./configs](./configs) directory to point to your container.

We leverage Google Container Registry's Vulnerability scanning feature to detect
potential security risks in this container, and
[None](https://console.cloud.google.com/gcr/images/cloud-foundation-cicd/global/cft/developer-tools-light@sha256:d881ce4ff2a73fa0877dd357af798a431a601b2ccfe5a140837bcb883cd3f011/details?tab=vulnz)
is reported.

## Features

### Event-triggered builds

Two presubmit and one postsubmit triggers are created by default.

* \[Presubmit\] `tf-validate`: Perform Terraform format and syntax check.
  * It does not access Terraform remote state.
* \[Presubmit\] `tf-plan`: Generate speculative plans to show a set of
    potential changes if the pending config changes are deployed.
  * It accesses Terraform remote state but does not lock it.
  * This also performs a non-blocking check for resource deletions. These
        are worth reviewing, as deletions are potentially destructive.
* \[Postsubmit\] `tf-apply`: Apply the terraform configs that are checked into
    the config source repo.
  * It accesses Terraform remote state and locks it.
  * This trigger is only applicable post-submit.
  * When this trigger is set in the Terraform engine config, the Cloud Build
        service account is given broader permissions to be able to make changes
        to the infrastructure.

Every new push to the Pull Request at the configured branches automatically
triggers presubmit runs. To manually re-trigger CI jobs, comment `/gcbrun` in
the Pull Ruquest. Presubmit Cloud Build results are posted as a Cloud Build job
link in the Pull Request. Failures of these presubmits should be configured to
block Pull Request submissions.

The postsubmit Cloud Build job automatically starts after a Pull Ruquest is
submitted to a configured branch. To view the result of the Cloud Build run, go
to [Build history](https://console.cloud.google.com/cloud-build/builds) and look
for your commit to view the Cloud Build job triggered by your merged commit.

The `build_viewers` members can view detailed log output.

The triggers all use a [helper runner script](./configs/run.sh) to perform
actions. The `MODULES` var within the script lists the modules that are managed
(relative to the `terraform_root` var) by the triggers and the order they are
run.

### Multi environment CICD workflow

You can configure multi environment CICD by using the `envs` block in the `cicd`
template. Triggers for each environment can be configured separately.

In each `env` block:

* `branch_name` defines the exact name of the branch that corresponds to the
    environment. Changes made to that branch will trigger CICD pipelines for its
    linked environment.
* `triggers` defines the trigger configurations for this environment.
* `managed_dirs` defines the order and list of directories in the generated
    folder that should be managed by the CICD pipelines created and configured
    for the corresponding environment.

TIP: Use a `shared` branch to manage shared components of the infrastructure,
such as `devops`, `groups`, `audit`, and `folders`. Changes made to those
templates and components should be pushed to the `shared` branch and deployed by
its own CICD pipelines.

When you would like to make a change to your infrastructure, push and merge the
changes to `dev` branch first. Deploy and verify the changes in the `dev`
environment. Once they look good, merge the `dev` branch to the `prod` branch,
so the same changes can be promoted to the `prod` environment.

```hcl
envs = [
  {
    name        = "shared"
    branch_name = "shared"
    triggers = {
      validate = {}
      plan = {}
      apply = {}
    }
    managed_dirs = ["devops", "groups", "audit", "folders"]
  },
  {
    name        = "dev"
    branch_name = "dev"
    triggers = {
      validate = {}
      plan = {}
      apply = {}
    }
    managed_dirs = ["dev/data"]
  },
  {
    name        = "prod"
    branch_name = "main"
    triggers = {
      validate = {}
      plan = {}
      apply = {}
    }
    managed_dirs = ["prod/data"]
  }
]
```

### Scheduled builds

You can configure the triggers to be run at a specified schedule via the
`run_on_schedule` attribute in each trigger block. The schedule is defined using
the
[unix-cron format](https://cloud.google.com/scheduler/docs/configuring/cron-job-schedules#defining_the_job_schedule).
Note that to use the scheduling feature, additional attribute `scheduler_region`
must be specified under the `cicd` template. An App Engine application will be
enabled and created behind the scenes, and supported regions can be found
[here](https://cloud.google.com/appengine/docs/locations).

### CICD for `devops` project itself

The CICD service account can manage a subset of resources (e.g. APIs) within its
own project (`devops` project). This allows users to have low risk changes made
in the `devops` project deployed through the standard Cloud Build pipelines,
without needing to apply it manually. To do so, add the `devops` module (that
hosts the devops project) in the `managed_modules` list in the CICD Terraform
Engine config block. Other changes in the `devops` project outside the approved
set (APIs) will still need to be made manually.

A common use case for this is when adding a new resource in a project that
requires a new API to be enabled. You must add the API in both the resource's
project as well as the `devops` project. With the feature above, the CICD can
deploy both changes for you.

### Deletion check allowlist

The deletion check run as part of the `tf-plan` trigger optionally accepts an
allowlist of resources to ignore, using
[grep extended regex patterns](https://en.wikipedia.org/wiki/Regular_expression#POSIX_extended)
matched against the Terraform resource **address** from the plan.

To configure an allowlist:

1. Create a file `tf-deletion-allowlist.txt` in the `cicd/configs/` directory.
2. Add patterns to it, one per line.

Example:

```text
network
^module.cloudsql.module.safer_mysql.google_sql_database.default$
google_sql_user.db_users\["user-creds"\]
```

Each line allows, respectively:

1. Any resource whose address contains the string "network".
2. A specific resource within a module.
3. A specific resource with a generated name, i.e. from `for_each` or `count`.
