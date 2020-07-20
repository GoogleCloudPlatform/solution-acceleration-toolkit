# Untitled object in Devops Recipe Schema

```txt
undefined#/properties/project
```

Config for the project to host devops related resources such as state bucket and CICD.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                    |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [devops.schema.json\*](../../../../../../../../../../tmp/182028425/devops.schema.json "open original schema") |

## project Type

`object` ([Details](devops-properties-project.md))

# undefined Properties

| Property                  | Type     | Required | Nullable       | Defined by                                                                                                                |
| :------------------------ | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------ |
| [owners](#owners)         | `array`  | Optional | cannot be null | [Devops Recipe](devops-properties-project-properties-owners.md "undefined#/properties/project/properties/owners")         |
| [project_id](#project_id) | `string` | Optional | cannot be null | [Devops Recipe](devops-properties-project-properties-project_id.md "undefined#/properties/project/properties/project_id") |

## owners

            List of members to transfer ownership of the project to.
            NOTE: By default the creating user will be the owner of the project.
            Thus, there should be a group in this list and you must be part of that group,
            so a group owns the project going forward.


`owners`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-project-properties-owners.md "undefined#/properties/project/properties/owners")

### owners Type

`string[]`

## project_id

ID of project.


`project_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-project-properties-project_id.md "undefined#/properties/project/properties/project_id")

### project_id Type

`string`
