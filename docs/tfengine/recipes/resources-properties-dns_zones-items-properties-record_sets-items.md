# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/dns_zones/items/properties/record_sets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-dns_zones-items-properties-record_sets-items.md))

# undefined Properties

| Property            | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                               |
| :------------------ | --------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)       | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-name.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/name")       |
| [records](#records) | `array`   | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-records.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/records") |
| [ttl](#ttl)         | `integer` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-ttl.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/ttl")         |
| [type](#type)       | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-type.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/type")       |

## name

Name of record set.


`name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-name.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/name")

### name Type

`string`

## records

Data of the record set.


`records`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-records.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/records")

### records Type

`string[]`

## ttl

Time to live of this record set, in seconds.


`ttl`

-   is optional
-   Type: `integer`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-ttl.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/ttl")

### ttl Type

`integer`

## type

Type of record set.


`type`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets-items-properties-type.md "undefined#/properties/dns_zones/items/properties/record_sets/items/properties/type")

### type Type

`string`
