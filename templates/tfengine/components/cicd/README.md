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

1. Before deploying CICD Terraform resources, install the Cloud Build app and
    [connect your GitHub repository](https://console.cloud.google.com/cloud-build/triggers/connect)
    to your Cloud project by following the steps in
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
    configured to block Pull Request submissions. The `build_viewers` members
    can view detailed log output.

    * `tf-validate`: Perform Terraform format and syntax check.
    * `tf-plan`: Generate speculative plans to show a set of potential changes
        if the pending config changes are deployed.
        * This also performs a non-blocking check for resource deletions.
            These are worth reviewing, as deletions are potentially destructive.
    * `tf-apply`: Apply the terraform configs that are checked into the Github
        repo. This trigger is only applicable post-submit. When this trigger is
        set in the Terraform engine config, the Cloud Build service account is
        given broader permissions to be able to make changes to the
        infrastructure.

    The triggers all use a [helper runner script](./configs/run.sh) to perform
    actions. The `MODULES` var within the script lists the modules that are
    managed (relative to the `terraform_root` var) by the triggers and the order
    they are run.

    **NOTE**: The CICD service account can manage a subset of resources (e.g.
    APIs) within its own project (`devops` project). This allows users to have
    low risk changes made in the `devops` project deployed through the standard
    Cloud Build pipelines, without needing to apply it manually. To do so, add
    the `devops` module (that hosts the devops project) in the `managed_modules`
    list in the CICD Terraform Engine config block. Other changes in the
    `devops` project outside the approved set (APIs) will still need to be made
    manually.

    A common use case for this is when adding a new resource in a project that
    requires a new API to be enabled. You must add the API in both the
    resource's project as well as the `devops` project. With the feature above,
    the CICD can deploy both changes for you.

## Operation

### Continuous integration (presubmit)

Presubmit Cloud Build results are posted as a Cloud Build job link in the Pull
Request. They should be configured to block Pull Request submissions.

Every new push to the Pull Request at the configured branches automatically
triggers presubmit runs. To manually re-trigger CI jobs, comment `/gcbrun` in
the Pull Ruquest.

### Continuous deployment (postsubmit)

The postsubmit Cloud Build job automatically starts after a Pull Ruquest is
submitted to a configured branch. To view the result of the Cloud Build run, go
to [Build history](https://console.cloud.google.com/cloud-build/builds) and look
for your commit to view the Cloud Build job triggered by your merged commit.

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
