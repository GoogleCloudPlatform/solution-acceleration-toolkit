# Continuous Integration (CI) and Continuous Deployment (CD)

This directory defines the resources that need to be deployed manually
to setup CICD pipelines of Terraform configs.

The CI and CD pipelines use
[Google Cloud Build](https://cloud.google.com/cloud-build) and
[Cloud Build Triggers](https://cloud.google.com/cloud-build/docs/automating-builds/create-manage-triggers)
to detect changes in the repo, trigger builds and run the workloads.

## Setup

1. In the Terraform Engine config, add a `CICD` block under the `foundation`
    recipe and specify the following attributes:

    * `parent_type`: Type of parent GCP resource to allow CICD to manage:
        can be "organization" or "folder"
    * `parent_id`: ID of parent GCP resource to allow CICD to manage:
        can be the organization ID or folder ID according to parent_type.
    * `project_id`: Project ID of the `devops` project
    * `state_bucket`: Name of the state bucket
    * `github`: Configuration block for GitHub Cloud Build triggers,
      which supports:
      * `owner`: GitHub repo owner
      * `name`: GitHub repo name
    * `cloud_source_repository`: Configuration block for Google Cloud
      Source Repository Cloud Build triggers, which supports:
      * `name`: Cloud Source Repository repo name
    * `branch_regex`: Regex of the branches to set the Cloud Build Triggers to
        monitor
    * `continuous_deployment_enabled`: Whether or not to enable continuous
        deployment of Terraform configs
    * `trigger_enabled`: Whether or not to enable all Cloud Build Triggers
    * `terraform_root`: Path of the directory relative to the repo root
        containing the Terraform configs
    * `build_viewers`: IAM members to grant cloudbuild.builds.viewer role
        in the devops project to see CICD results
    * `managed_services`: APIs to enable in the devops project so Cloud
        Build Service Account can manage those services in other projects

1. Generate the CICD Terraform configs and Cloud Build configs using the
    Terraform Engine. Only the Terraform resources in the current directory,
    i.e. the `cicd/` directory under root, need to be deplopyed manually.

1. Before deployment CICD Terraform resources, follow
    [installing_the_cloud_build_app](https://cloud.google.com/cloud-build/docs/automating-builds/create-github-app-triggers#installing_the_cloud_build_app)
    to install the Cloud Build app and connect your GitHub repository to your
    Cloud project. To perform this operation, you need Admin permission in that
    GitHub repository. This currently cannot be done through automation.

1. Once the GitHub repo is connected, run the following commands in this
    directory to enable necessary APIs, grant Cloud Build Service Account
    necessary permissions and create Cloud Build Triggers:

    ```shell
    terraform init
    terraform plan
    terraform apply
    ```

    Two presubmit triggers are created by default. Build/test status and results
    will be posted in the Pull Request. Failures of these presubmits should
    be configured to block Pull Request submissions.

    1. `tf-validate`: Perform Terraform format and syntax check.
    1. `tf-plan`: Generate speculative plans to show a set of potential changes
        if the pending config changes are deployed.

    If `continuous_deployment_enabled` is set to `true` in your Terraform Engine
    config, `continuous_deployment_enabled` will be set to `true` in
    [terraform.tfvars](./terraform.tfvars) to create an additional Cloud Build
    Trigger and grant the Cloud Build Service Account broder permissions. So
    after the Pull Request is approved and submitted, this postsubmit deployment
    job can automatically apply the config changes to GCP.

    After the triggers are created, to temporarily disable or re-enable them,
    set the `trigger_enabled` in [terraform.tfvars](./terraform.tfvars) to
    `false` or `true` and apply the changes by running:

    ```shell
    terraform init
    terraform plan
    terraform apply
    ```

## Operation

### Continuous Integration (presubmit)

Presubmit Cloud Build results will be posted as a Cloud Build job link in the
Pull Request, and they should be configured to block Pull Request submissions.

Every new push to the Pull Request at the configured branches will automatically
trigger presubmit runs. To manually re-trigger CI jobs, comment `/gcbrun` in the
Pull Ruquest.

### Continuous Deployment (postsubmit)

Postsubmit Cloud Build job will automatically start when a Pull Ruquest is
submitted to a configured branch. To view the result of the Cloud Build run, go
to <https://console.cloud.google.com/cloud-build/builds> and look for your commit
to view the Cloud Build job triggered by your merged commit.

The Postsubmit Cloud Build Trigger monitors and deploys changes made to `live/`
folder only. Other changes made to `bootstrap/`, `cicd/` and other folders at
root should be deployed manually.
