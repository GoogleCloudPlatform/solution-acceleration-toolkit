# Recipe for creating GCP folders. Schema

```txt
undefined
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [folder.schema.json](folder.schema.json "open original schema") |

## Recipe for creating GCP folders. Type

unknown ([Recipe for creating GCP folders.](folder.md))

# Recipe for creating GCP folders. Properties

| Property                                                      | Type      | Required | Nullable       | Defined by                                                                                                                                 |
| :------------------------------------------------------------ | --------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| [add_parent_folder_dependency](#add_parent_folder_dependency) | `boolean` | Optional | cannot be null | [Recipe for creating GCP folders.](folder-properties-add_parent_folder_dependency.md "undefined#/properties/add_parent_folder_dependency") |
| [display_name](#display_name)                                 | `string`  | Required | cannot be null | [Recipe for creating GCP folders.](folder-properties-display_name.md "undefined#/properties/display_name")                                 |
| [parent_id](#parent_id)                                       | `string`  | Optional | cannot be null | [Recipe for creating GCP folders.](folder-properties-parent_id.md "undefined#/properties/parent_id")                                       |
| [parent_type](#parent_type)                                   | `string`  | Optional | cannot be null | [Recipe for creating GCP folders.](folder-properties-parent_type.md "undefined#/properties/parent_type")                                   |

## add_parent_folder_dependency

        Whether to automatically add dependency on parent folder.
        Only applicable if 'parent_type' is folder. Defaults to false.
        If the parent folder is created in the same config as this folder then
        this field should be set to true to create a dependency and pass the
        folder id once it has been created.


`add_parent_folder_dependency`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Recipe for creating GCP folders.](folder-properties-add_parent_folder_dependency.md "undefined#/properties/add_parent_folder_dependency")

### add_parent_folder_dependency Type

`boolean`

## display_name

Name of folder.


`display_name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP folders.](folder-properties-display_name.md "undefined#/properties/display_name")

### display_name Type

`string`

## parent_id

        ID of parent GCP resource to apply the policy: can be one of the organization ID or folder ID according to parent_type.


`parent_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP folders.](folder-properties-parent_id.md "undefined#/properties/parent_id")

### parent_id Type

`string`

### parent_id Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^[0-9]{8,25}$
```

[try pattern](https://regexr.com/?expression=%5E%5B0-9%5D%7B8%2C25%7D%24 "try regular expression with regexr.com")

## parent_type

Type of parent GCP resource to apply the policy: can be one of 'organization' or 'folder'.


`parent_type`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP folders.](folder-properties-parent_type.md "undefined#/properties/parent_type")

### parent_type Type

`string`

### parent_type Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^organization|folder$
```

[try pattern](https://regexr.com/?expression=%5Eorganization%7Cfolder%24 "try regular expression with regexr.com")
