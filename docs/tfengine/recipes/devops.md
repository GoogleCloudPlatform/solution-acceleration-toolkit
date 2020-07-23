# Devops Recipe

<!-- These files are auto generated -->

## Properties

### admins_group

Group who will be given org admin access.

Type: string

### billing_account

ID of billing account to attach to this project.

Type: string

### enable_bootstrap_gcs_backend

Whether to enable GCS backend for the bootstrap deployment. Defaults to false.
Since the bootstrap deployment creates the state bucket, it cannot back the state
to the GCS bucket on the first deployment. Thus, this field should be set to true
after the bootstrap deployment has been applied. Then the user can run
`terraform init` in the bootstrapd deployment to transfer the state
from local to GCS.

Type: boolean

### parent_id

ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.

Type: string

### parent_type

Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'.

Type: string

### project

Config for the project to host devops resources such as remote state and CICD.

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
