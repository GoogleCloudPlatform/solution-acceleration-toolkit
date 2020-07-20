# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items.md))

# undefined Properties

| Property              | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                                           |
| :-------------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ip_range](#ip_range) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items-properties-ip_range.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges/items/properties/ip_range") |
| [name](#name)         | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items-properties-name.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges/items/properties/name")         |

## ip_range

IP range for the secondary range.


`ip_range`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items-properties-ip_range.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges/items/properties/ip_range")

### ip_range Type

`string`

## name

Name of secondary range.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items-properties-name.md "undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges/items/properties/name")

### name Type

`string`
