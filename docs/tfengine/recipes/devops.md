
# Devops Recipe

## Properties

### admins_group

Group who will be given org admin access.



### billing_account

ID of billing account to attach to this project.



### cicd

Config for CICD. If unset there will be no CICD.



### enable_bootstrap_gcs_backend

Whether to enable GCS backend for the bootstrap deployment. Defaults to false.
Since the bootstrap deployment creates the state bucket, it cannot back the state
to the GCS bucket on the first deployment. Thus, this field should be set to true
after the bootstrap deployment has been applied. Then the user can run `terraform init`
in the bootstrapd deployment to transfer the state from local to GCS.




### enable_terragrunt

Whether to convert to a Terragrunt deployment. If set to "false", generate Terraform-only
configs and the CICD pipelines will only use Terraform. Default to "true".




### parent_id

ID of parent GCP resource to apply the policy: can be one of the organization ID,
folder ID according to parent_type.




### parent_type

Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'.



### project

Config for the project to host devops related resources such as state bucket and CICD.



### state_bucket

Name of Terraform remote state bucket.



### storage_location

Location of state bucket.



