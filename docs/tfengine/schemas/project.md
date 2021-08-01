# Project Recipe

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| billing_account | ID of billing account to attach to this project. | string | false | - | - |
| parent_id | ID of parent GCP resource to apply the policy        Can be one of the organization ID or folder ID according to parent_type. | string | false | - | - |
| parent_type | Type of parent GCP resource to apply the policy        Can be one of 'organization' or 'folder'. | string | false | - | ^organization\|folder$ |
| project | Config for the project. | object | true | - | - |
| project.api_identities | The list of service identities (Google Managed service account for the API) to            force-create for the project (e.g. in order to grant additional roles).            APIs in this list will automatically be appended to `apis`.            Not including the API in this list will follow the default behaviour for identity            creation (which is usually when the first resource using the API is created).            Any roles (e.g. service agent role) must be explicitly listed.            See <https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles>            for a list of related roles. | array(object) | false | [] | - |
| project.api_identities.api | The API whose default Service Agent will be force-created and granted the roles. Example: healthcare.googleapis.com. | string | true | - | - |
| project.api_identities.roles | Roles to granted to the API Service Agent. | array(string) | true | - | - |
| project.apis | APIs to enable in the project. | array(string) | false | [] | - |
| project.exists | Whether this project exists. | boolean | false | false | - |
| project.is_shared_vpc_host | Whether this project is a shared VPC host. | boolean | false | false | - |
| project.project_id | ID of project to create and/or provision resources in. | string | true | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| project.shared_vpc_attachment | If set, treats this project as a shared VPC service project. | object | false | - | - |
| project.shared_vpc_attachment.host_project_id | ID of host project to connect this project to. | string | true | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| project.shared_vpc_attachment.subnets | Subnets within the host project to grant this project access to. | array(object) | false | [] | - |
| project.shared_vpc_attachment.subnets.compute_region | Region of subnet. | string | false | - | - |
| project.shared_vpc_attachment.subnets.name | Name of subnet. | string | true | - | - |
| resources | Resources in this project.        See [resources.md](./resources.md) for schema. | - | false | - | - |
| state_bucket | Bucket to store remote state. | string | false | - | - |
| state_path_prefix | Path within bucket to store state. Defaults to the template's output_path. | string | false | - | - |
| terraform_addons | Additional Terraform configuration for the project deployment.        For schema see ./deployment.hcl. | - | false | - | - |
