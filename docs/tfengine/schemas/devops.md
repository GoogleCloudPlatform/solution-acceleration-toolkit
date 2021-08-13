# Devops Recipe

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| admins_group | Group which will be given admin access to the folder or organization. | object | true | - | - |
| admins_group.customer_id | Customer ID of the organization to create the group in. See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id> for how to obtain it. | string | false | - | - |
| admins_group.description | Description of the group. | string | false | - | - |
| admins_group.display_name | Display name of the group. | string | false | - | - |
| admins_group.exists | Whether or not the group exists already. It will be created if not. | boolean | false | false | - |
| admins_group.id | Email address of the group. | string | true | - | - |
| admins_group.owners | Owners of the group. | array(string) | false | - | - |
| billing_account | ID of billing account to attach to this project. | string | false | - | - |
| enable_gcs_backend | Whether to enable GCS backend for the devops module. Defaults to false.<br><br>Since the devops module creates the state bucket, it cannot back up the state to the GCS bucket on the first module. Thus, this field should be set to false initially.<br><br>After the devops module has been applied once and the state bucket exists, the user should set this to true and regenerate the configs.<br><br>To migrate the state from local to GCS, run `terraform init` on the module. | boolean | false | false | - |
| parent_id | ID of parent GCP resource to apply the policy. Can be one of the organization ID or folder ID according to parent_type. See <https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy> to learn more about resource hierarchy. | string | false | - | ^[0-9]{8,25}$ |
| parent_type | Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'. | string | false | - | ^organization\|folder$ |
| project | Config for the project to host devops resources such as remote state and CICD. | object | true | - | - |
| project.apis | List of APIs enabled in the devops project.<br><br>NOTE: If a CICD is deployed within this project, then the APIs of all resources managed by the CICD must be listed here (even if the resources themselves are in different projects). | array(string) | false | - | - |
| project.owners_group | Group which will be given owner access to the project. NOTE: By default, the creating user will be the owner of the project. However, this group will own the project going forward. Make sure to include yourselve in the group, | object | true | - | - |
| project.owners_group.customer_id | Customer ID of the organization to create the group in. See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id> for how to obtain it. | string | false | - | - |
| project.owners_group.description | Description of the group. | string | false | - | - |
| project.owners_group.display_name | Display name of the group. | string | false | - | - |
| project.owners_group.exists | Whether or not the group exists already. It will be created if not. | boolean | false | false | - |
| project.owners_group.id | Email address of the group. | string | true | - | - |
| project.owners_group.owners | Owners of the group. | array(string) | false | - | - |
| project.project_id | ID of project. | string | true | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| state_bucket | Name of Terraform remote state bucket. | string | false | - | - |
| storage_location | Location of state bucket. | string | false | - | - |
