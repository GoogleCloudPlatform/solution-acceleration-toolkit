
# Recipe for creating GCP projects.

## Properties

## add_parent_folder_dependency

        Whether to automatically add dependency on parent folder.
        Only applicable if 'parent_type' is folder. Defaults to false.
        If the parent folder is created in the same config as this project then
        this field should be set to true to create a dependency and pass the
        folder id once it has been created.



## deployments

        Map of deployment name to resources config.
        Each key will be a directory in the output path.
        For resource schema see ./resources.hcl.



## parent_id

        ID of parent GCP resource to apply the policy: can be one of the organization ID or folder ID according to parent_type.



## parent_type

Type of parent GCP resource to apply the policy: can be one of 'organization' or 'folder'.


## project

Config for the project.


