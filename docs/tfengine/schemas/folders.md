# Folder Recipe

<!-- These files are auto generated -->

## Properties
| Property 	| Description 						| Type 	   			   | Required			   		   | Default             | Pattern 			 			 |
| --------- | ----------------------- | ---------------- | --------------------- | ------------------- | ------------------- |
| folders | Folders to create. | array(object) | true | - | - |
| folders.display_name | Name of folder. | string | true | - | - |
| folders.parent | Parent of folder. | string | false | - | - |
| folders.resource_name | Override for Terraform resource name. If unset, defaults to normalized display_name.              Normalization will make all characters alphanumeric with underscores. | string | false | - | - |
| parent_id | ID of parent GCP resource to apply the policy.        Can be one of the organization ID or folder ID according to parent_type. | string | false | - | ^[0-9]{8,25}$ |
| parent_type | Type of parent GCP resource to apply the policy.        Can be one of 'organization' or 'folder'. | string | false | - | ^organization|folder$ |
