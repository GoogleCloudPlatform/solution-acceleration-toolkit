# Devops Recipe

<!-- These files are auto generated -->

## Properties

### admins_group

Group which will be given admin access to the folder or organization.
It will be created if 'exists' is false.

Type: object

### admins_group.customer_id

Customer ID of the organization to create the group in.
See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
for how to obtain it.

Type: string

### admins_group.description

Description of the group.

Type: string

### admins_group.display_name

Display name of the group.

Type: string

### admins_group.exists

Whether or not the group exists already. Default to 'false'.

Type: boolean

### admins_group.id

Email address of the group.

Type: string

### admins_group.owners

Owners of the group.

Type: array(string)

### billing_account

ID of billing account to attach to this project.

Type: string

### enable_gcs_backend

Whether to enable GCS backend for the devops module.
Defaults to false.

Since the devops module creates the state bucket, it cannot back up
the state to the GCS bucket on the first module. Thus, this field
should be set to false initially.

After the devops module has been applied once and the state bucket
exists, the user should set this to true and regenerate the configs.

To migrate the state from local to GCS, run `terraform init` on the
module.

Type: boolean

### parent_id

ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.

Type: string

Pattern: ^[0-9]{8,25}$

### parent_type

Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'.

Type: string

Pattern: ^organization|folder$

### project

Config for the project to host devops resources such as remote state and CICD.

Type: object

### project.apis

List of APIs enabled in the devops project.

NOTE: If a CICD is deployed within this project, then the APIs of
all resources managed by the CICD must be listed here
(even if the resources themselves are in different projects).

### project.owners_group

Group which will be given owner access to the project.
It will be created if 'exists' is false.
NOTE: By default, the creating user will be the owner of the project.
However, this group will own the project going forward. Make sure to include
yourselve in the group,

Type: object

### project.owners_group.customer_id

Customer ID of the organization to create the group in.
See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
for how to obtain it.

Type: string

### project.owners_group.description

Description of the group.

Type: string

### project.owners_group.display_name

Display name of the group.

Type: string

### project.owners_group.exists

Whether or not the group exists already. Default to 'false'.

Type: boolean

### project.owners_group.id

Email address of the group.

Type: string

### project.owners_group.owners

Owners of the group.

Type: array(string)

### project.project_id

ID of project.

Type: string

Pattern: ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$

### state_bucket

Name of Terraform remote state bucket.

Type: string

### storage_location

Location of state bucket.

Type: string
