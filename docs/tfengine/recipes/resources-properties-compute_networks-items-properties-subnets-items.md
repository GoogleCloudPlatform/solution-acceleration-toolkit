# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_networks/items/properties/subnets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-compute_networks-items-properties-subnets-items.md))

# undefined Properties

| Property                                                              | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                       |
| :-------------------------------------------------------------------- | --------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [cloud_sql_private_service_access](#cloud_sql_private_service_access) | `boolean` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-cloud_sql_private_service_access.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/cloud_sql_private_service_access") |
| [compute_region](#compute_region)                                     | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-compute_region.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/compute_region")                                     |
| [ip_range](#ip_range)                                                 | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-ip_range.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/ip_range")                                                 |
| [name](#name)                                                         | `string`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-name.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/name")                                                         |
| [secondary_ranges](#secondary_ranges)                                 | `array`   | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges")                                 |

## cloud_sql_private_service_access

Whether to enable Cloud SQL private service access. Defaults to false.


`cloud_sql_private_service_access`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-cloud_sql_private_service_access.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/cloud_sql_private_service_access")

### cloud_sql_private_service_access Type

`boolean`

## compute_region

Region to create subnet in. Can be defined in global data block.


`compute_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-compute_region.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/compute_region")

### compute_region Type

`string`

## ip_range

IP range of the subnet.


`ip_range`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-ip_range.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/ip_range")

### ip_range Type

`string`

## name

Name of subnet.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-name.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/name")

### name Type

`string`

## secondary_ranges

Secondary ranges of the subnet.


`secondary_ranges`

-   is optional
-   Type: `object[]` ([Details](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges")

### secondary_ranges Type

`object[]` ([Details](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items.md))
