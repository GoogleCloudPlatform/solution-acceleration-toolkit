# Google Cloud Organization Policy Recipe

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| allowed_ip_forwarding_vms | See templates/policygen/org_policies/variables.tf.        If not specified, default to allow all. | array(string) | false | - | - |
| allowed_policy_member_customer_ids | See templates/policygen/org_policies/variables.tf. Must be specified to restrict        domain members that can be assigned IAM roles. Obtain the ID by following        <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>. | array(string) | true | - | - |
| allowed_public_vms | See templates/policygen/org_policies/variables.tf.        If not specified, default to deny all. | array(string) | false | - | - |
| allowed_shared_vpc_host_projects | See templates/policygen/org_policies/variables.tf.        If not specified, default to allow all. | array(string) | false | - | - |
| allowed_trusted_image_projects | See templates/policygen/org_policies/variables.tf.        If not specified, default to allow all. | array(string) | false | - | - |
| output_path | For internal use. Default state path prefix for Terraform Engine deployments. | string | false | - | - |
| parent_id | ID of parent GCP resource to apply the policy: can be one of the organization ID,        folder ID, or project ID according to parent_type. | string | false | - | ^[0-9]{8,25}$ |
| parent_type | Type of parent GCP resource to apply the policy: can be one of "organization",        "folder", or "project". | string | false | - | ^organization\|folder\|project$ |
