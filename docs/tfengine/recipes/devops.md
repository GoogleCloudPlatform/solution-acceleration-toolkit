# Devops Recipe

## Properties

### admins_group

Group who will be given org admin access.

Type: string


### billing_account

ID of billing account to attach to this project.

Type: string


### cicd

Config for CICD. If unset there will be no CICD.

Type: object


### cicd.apply_trigger

Config block for the postsubmit apply/deployyemt Cloud Build trigger. If specified,
create the trigger and grant the Cloud Build Service Account necessary permissions
to perform the build.


Type: object


### cicd.apply_trigger.disable

Whether or not to disable automatic triggering from a PR/push to branch. Default
to false.


Type: boolean


### cicd.branch_regex

Regex of the branches to set the Cloud Build Triggers to monitor.

Type: string


### cicd.build_viewers

IAM members to grant `cloudbuild.builds.viewer` role in the devops project to see CICD results.

Type: array(string)


### cicd.cloud_source_repository

Config for Google Cloud Source Repository Cloud Build triggers.

Type: object


### cicd.cloud_source_repository.name

Cloud Source Repository repo name.
The Cloud Source Repository should be hosted under the devops project.


Type: string


### cicd.github

Config for GitHub Cloud Build triggers.

Type: object


### cicd.github.name

GitHub repo name.

Type: string


### cicd.github.owner

GitHub repo owner.

Type: string


### cicd.managed_services

APIs to enable in the devops project so the Cloud Build service account can manage
those services in other projects.


Type: array(string)


### cicd.plan_trigger

Config block for the presubmit plan Cloud Build trigger. If specified, create
the trigger and grant the Cloud Build Service Account necessary permissions to perform
the build.


Type: object


### cicd.plan_trigger.disable

Whether or not to disable automatic triggering from a PR/push to branch. Default
to false.


Type: boolean


### cicd.terraform_root

Path of the directory relative to the repo root containing the Terraform configs.

Type: string


### cicd.validate_trigger

Config block for the presubmit validation Cloud Build trigger. If specified, create
the trigger and grant the Cloud Build Service Account necessary permissions to perform
the build.


Type: object


### cicd.validate_trigger.disable

Whether or not to disable automatic triggering from a PR/push to branch. Default
to false.


Type: boolean


### enable_bootstrap_gcs_backend

Whether to enable GCS backend for the bootstrap deployment. Defaults to false.
Since the bootstrap deployment creates the state bucket, it cannot back the state
to the GCS bucket on the first deployment. Thus, this field should be set to true
after the bootstrap deployment has been applied. Then the user can run `terraform init`
in the bootstrapd deployment to transfer the state from local to GCS.


Type: boolean


### enable_terragrunt

Whether to convert to a Terragrunt deployment. If set to "false", generate Terraform-only
configs and the CICD pipelines will only use Terraform. Default to "true".


Type: boolean


### parent_id

ID of parent GCP resource to apply the policy: can be one of the organization ID,
folder ID according to parent_type.


Type: string


### parent_type

Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'.

Type: string


### project

Config for the project to host devops related resources such as state bucket and CICD.

Type: object


### project.owners

List of members to transfer ownership of the project to.
NOTE: By default the creating user will be the owner of the project.
Thus, there should be a group in this list and you must be part of that group,
so a group owns the project going forward.


Type: array(string)


### project.project_id

ID of project.

Type: string


### state_bucket

Name of Terraform remote state bucket.

Type: string


### storage_location

Location of state bucket.

Type: string


