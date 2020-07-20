# Untitled object in Recipe for creating GCP projects. Schema

```txt
undefined#/properties/project/properties/shared_vpc_attachment
```

If set, treats this project as a shared VPC service project.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [project.schema.json\*](../../../../../../../../../../tmp/182028425/project.schema.json "open original schema") |

## shared_vpc_attachment Type

`object` ([Details](project-properties-project-properties-shared_vpc_attachment.md))

# undefined Properties

| Property                            | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                 |
| :---------------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [host_project_id](#host_project_id) | `string` | Required | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-host_project_id.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/host_project_id") |
| [subnets](#subnets)                 | `array`  | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-subnets.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets")                 |

## host_project_id

ID of host project to connect this project to.


`host_project_id`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-host_project_id.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/host_project_id")

### host_project_id Type

`string`

## subnets

Subnets within the host project to grant this project access to.


`subnets`

-   is optional
-   Type: `object[]` ([Details](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items.md))
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-subnets.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets")

### subnets Type

`object[]` ([Details](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items.md))
