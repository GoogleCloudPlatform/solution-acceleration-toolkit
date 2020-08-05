# Google Cloud Organization Policies Config Schema

<!-- These files are auto generated -->

## Properties

### allowed_ip_forwarding_vms

See templates/policygen/org_policies/variables.tf.
If not specified, default to allow all.

Type: array(string)

### allowed_policy_member_customer_ids

See templates/policygen/org_policies/variables.tf.

Must be specified to restrict domain members that can be assigned IAM roles.

See
[guide](https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id).

Type: array(string)

### allowed_public_vms

See templates/policygen/org_policies/variables.tf.
If not specified, default to deny all.

Type: array(string)

### allowed_shared_vpc_host_projects

See templates/policygen/org_policies/variables.tf.
If not specified, default to allow all.

Type: array(string)

### allowed_trusted_image_projects

See templates/policygen/org_policies/variables.tf.
If not specified, default to allow all.

Type: array(string)

### output_path

For internal use. Default state path prefix for Terraform Engine deployments.

Type: string

### parent_id

ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.

Type: string

### parent_type

Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'."

Type: string
