# Continuous integration (CI) and continuous deployment (CD)

This directory defines the resources that need to be deployed manually to set up
CICD pipelines of Terraform configs.

The CI and CD pipelines use
[Google Cloud Build](https://cloud.google.com/cloud-build) and
[Cloud Build triggers](https://cloud.google.com/cloud-build/docs/automating-builds/create-manage-triggers)
to detect changes in the repo, trigger builds, and run the workloads.

## Setup

1. In the Terraform Engine config, add a `cicd` block under the `devops` recipe
    and specify the following attributes:

    * `github`: Configuration block for GitHub Cloud Build triggers, which
        supports:
        * `owner`: GitHub repo owner
        * `name`: GitHub repo name
    * `cloud_source_repository`: Configuration block for Google Cloud Source
        Repository Cloud Build triggers, which supports:
        * `name`: Cloud Source Repository repo name. The Cloud Source
            Repository should be hosted under the devops project.
    * `branch_regex`: Regex of the branches to set the Cloud Build Triggers to
        monitor.
    * `enable_continuous_deployment`: Whether or not to enable continuous
        deployment of Terraform configs.
    * `enable_triggers`: Whether or not to enable all Cloud Build triggers.
    * `enable_deployment_trigger`: Whether or not to enable the post-submit
        Cloud Build trigger to deploy Terraform configs. This is useful when you
        want to create the Cloud Build trigger and manually run it to deploy
        Terraform configs, but don't want it to be triggered automatically by a
        push to branch. The post-submit Cloud Build trigger for deployment will
        be disabled as long as one of `enable_triggers` or
        `enable_deployment_trigger` is set to `false`.
    * `terraform_root`: Path of the directory relative to the repo root
        containing the Terraform configs.
    * `build_viewers`: IAM members to grant `cloudbuild.builds.viewer` role in
        the devops project to see CICD results.

1. Generate the CICD Terraform configs and Cloud Build configs using the
    Terraform Engine. Only the Terraform resources in the current directory,
    that is, the `cicd/` directory under root, need to be deplopyed manually.

1. Before deploying CICD Terraform resources, install the Cloud Build app and
    connect your GitHub repository to your Cloud project by following the steps
    in
    [Installing the Cloud Build app](https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app).
    To perform this operation, you need Admin permission in that GitHub
    repository. This can't be done through automation.

1. After the GitHub repo is connected, run the following commands in this
    directory to enable the necessary APIs, grant the Cloud Build service
    account the necessary permissions, and create Cloud Build triggers:

    ```shell
    terraform init
    terraform plan
    terraform apply
    ```

    Two presubmit triggers are created by default. Build/test status and results
    are posted in the Pull Request. Failures of these presubmits should be
    configured to block Pull Request submissions.

    * `tf-validate`: Perform Terraform format and syntax check.
    * `tf-plan`: Generate speculative plans to show a set of potential changes
        if the pending config changes are deployed.
        * This also performs a non-blocking check for resource deletions.
            These are worth reviewing, as deletions are potentially destructive.

    If `enable_continuous_deployment` is set to `true` in your Terraform Engine
    config, `enable_continuous_deployment` will be set to `true` in
    [terraform.tfvars](./terraform.tfvars) to create an additional Cloud Build
    trigger and grant the Cloud Build service account broder permissions. After
    the Pull Request is approved and submitted, this postsubmit deployment job
    can automatically apply the config changes to Google Cloud.

    After the triggers are created, to temporarily disable or re-enable them,
    set the `enable_triggers` in [terraform.tfvars](./terraform.tfvars) to
    `false` or `true` and apply the changes by running the following commands:

    ```shell
    terraform init
    terraform plan
    terraform apply
    ```

## Operation

### Continuous integration (presubmit)

Presubmit Cloud Build results are posted as a Cloud Build job link in the Pull
Request. They should be configured to block Pull Request submissions.

Every new push to the Pull Request at the configured branches automatically
triggers presubmit runs. To manually re-trigger CI jobs, comment `/gcbrun` in
the Pull Ruquest.

### Deletion Check Allowlist

The deletion check optionally accepts an allowlist of resources to ignore, using
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

### Continuous deployment (postsubmit)

The postsubmit Cloud Build job automatically starts after a Pull Ruquest is
submitted to a configured branch. To view the result of the Cloud Build run, go
to [Build history](https://console.cloud.google.com/cloud-build/builds) and look
for your commit to view the Cloud Build job triggered by your merged commit.

The Postsubmit Cloud Build trigger monitors and deploys changes made to the
`live/` folder only. Changes made to `bootstrap/`, `cicd/`, and other folders at
root must be deployed manually.
