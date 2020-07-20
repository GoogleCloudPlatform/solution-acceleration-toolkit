# Recipe for creating GCP projects.

## Properties

### add_parent_folder_dependency

Whether to automatically add dependency on parent folder.
Only applicable if 'parent_type' is folder. Defaults to false.
If the parent folder is created in the same config as this project then
this field should be set to true to create a dependency and pass the
folder id once it has been created.



Type: boolean

### deployments

Map of deployment name to resources config.
Each key will be a directory in the output path.
For resource schema see ./resources.hcl.



Type: object

### parent_id

ID of parent GCP resource to apply the policy: can be one of the organization ID or folder ID according to parent_type.



Type: string

### parent_type

Type of parent GCP resource to apply the policy: can be one of 'organization' or 'folder'.


Type: string

### project

Config for the project.


Type: object

### project.apis

APIs to enable in the project.


Type: array(string)

### project.is_shared_vpc_host

Whether this project is a shared VPC host. Defaults to 'false'.


Type: boolean

### project.project_id

ID of project to create.


Type: string

### project.shared_vpc_attachment

If set, treats this project as a shared VPC service project.


Type: object

### project.terraform_addons

Additional Terraform configuration for the project deployment.
For schema see ./deployment.hcl.





### shared_vpc_attachment.host_project_id

ID of host project to connect this project to.


Type: string

### shared_vpc_attachment.subnets

Subnets within the host project to grant this project access to.


Type: array(object)

### subnets.compute_region

Region of subnet.


Type: string

### subnets.name

Name of subnet.


Type: string

