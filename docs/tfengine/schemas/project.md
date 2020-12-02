# Project Recipe

<!-- These files are auto generated -->

## Properties

### parent_id

ID of parent GCP resource to apply the policy
Can be one of the organization ID or folder ID according to parent_type.

Type: string

### parent_type

Type of parent GCP resource to apply the policy
Can be one of 'organization' or 'folder'.

Type: string

### project

Config for the project.

Type: object

### project.apis

APIs to enable in the project.

Type: array(string)

### project.exists

Whether this project exists. Defaults to 'false'.

Type: boolean

### project.is_shared_vpc_host

Whether this project is a shared VPC host. Defaults to 'false'.

Type: boolean

### project.project_id

ID of project to create and/or provision resources in.

Type: string

### project.shared_vpc_attachment

If set, treats this project as a shared VPC service project.

Type: object

### project.shared_vpc_attachment.host_project_id

ID of host project to connect this project to.

Type: string

### project.shared_vpc_attachment.subnets

Subnets within the host project to grant this project access to.

Type: array(object)

### project.shared_vpc_attachment.subnets.compute_region

Region of subnet.

Type: string

### project.shared_vpc_attachment.subnets.name

Name of subnet.

Type: string

### resources

Resources in this project.
See [resources.md](./resources.md) for schema.

### state_bucket

Bucket to store remote state.

Type: string

### state_path_prefix

Path within bucket to store state. Defaults to the template's output_path.

Type: string

### terraform_addons

Additional Terraform configuration for the project deployment.
For schema see ./deployment.hcl.
