# Folder Recipe

<!-- These files are auto generated -->

## Properties

### add_parent_folder_dependency

Whether to automatically add dependency on parent folder.
Only applicable if 'parent_type' is folder. Defaults to false.
If the parent folder is created in the same config as this folder then
this field should be set to true to create a dependency and pass the
folder id once it has been created.

Type: boolean

### display_name

Name of folder.

Type: string

### parent_id

ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.

Type: string

### parent_type

Type of parent GCP resource to apply the policy.
Can be one of 'organization' or 'folder'.

Type: string
