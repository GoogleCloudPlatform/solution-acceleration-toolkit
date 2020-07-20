# Untitled boolean in Recipe for creating GCP projects. Schema

```txt
undefined#/properties/add_parent_folder_dependency
```

        Whether to automatically add dependency on parent folder.
        Only applicable if 'parent_type' is folder. Defaults to false.
        If the parent folder is created in the same config as this project then
        this field should be set to true to create a dependency and pass the
        folder id once it has been created.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                      |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [project.schema.json\*](../../../../../../../../../../tmp/182028425/project.schema.json "open original schema") |

## add_parent_folder_dependency Type

`boolean`
