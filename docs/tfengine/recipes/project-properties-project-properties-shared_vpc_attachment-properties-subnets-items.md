# Untitled object in Recipe for creating GCP projects. Schema

```txt
undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [project.schema.json\*](../../../../../../../../../../tmp/182028425/project.schema.json "open original schema") |

## items Type

`object` ([Details](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items.md))

# undefined Properties

| Property                          | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                 |
| :-------------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [compute_region](#compute_region) | `string` | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items-properties-compute_region.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets/items/properties/compute_region") |
| [name](#name)                     | `string` | Required | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items-properties-name.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets/items/properties/name")                     |

## compute_region

Region of subnet.


`compute_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items-properties-compute_region.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets/items/properties/compute_region")

### compute_region Type

`string`

## name

Name of subnet.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment-properties-subnets-items-properties-name.md "undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets/items/properties/name")

### name Type

`string`
