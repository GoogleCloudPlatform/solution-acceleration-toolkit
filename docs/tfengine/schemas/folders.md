# Folder Recipe

<!-- These files are auto generated -->

## Properties

### folders

Folders to create.

Type: array(object)

### folders.display_name

Name of folder.

Type: string

### folders.parent

Parent of folder.

Type: string

### folders.resource_name

Override for Terraform resource name. If unset, defaults to normalized display_name.
Normalization will make all characters alphanumeric with underscores.

Type: string

### parent_id

ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.

Type: string

Pattern: ^[0-9]{8,25}$

### parent_type

Type of parent GCP resource to apply the policy.
Can be one of 'organization' or 'folder'.

Type: string

Pattern: ^organization|folder$
