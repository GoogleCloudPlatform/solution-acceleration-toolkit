# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/dns_zones/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-dns_zones-items.md))

# undefined Properties

| Property                        | Type          | Required | Nullable       | Defined by                                                                                                                                                                 |
| :------------------------------ | ------------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [domain](#domain)               | `string`      | Required | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-domain.md "undefined#/properties/dns_zones/items/properties/domain")               |
| [name](#name)                   | Not specified | Required | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-name.md "undefined#/properties/dns_zones/items/properties/name")                   |
| [record_sets](#record_sets)     | `array`       | Required | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets.md "undefined#/properties/dns_zones/items/properties/record_sets")     |
| [resource_name](#resource_name) | `string`      | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-resource_name.md "undefined#/properties/dns_zones/items/properties/resource_name") |
| [type](#type)                   | `string`      | Required | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-type.md "undefined#/properties/dns_zones/items/properties/type")                   |

## domain

Domain of DNS zone. Must end with period.


`domain`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-domain.md "undefined#/properties/dns_zones/items/properties/domain")

### domain Type

`string`

### domain Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^.+\.$
```

[try pattern](https://regexr.com/?expression=%5E.%2B%5C.%24 "try regular expression with regexr.com")

## name

Name of DNS zone.


`name`

-   is required
-   Type: unknown
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-name.md "undefined#/properties/dns_zones/items/properties/name")

### name Type

unknown

## record_sets

Records managed by the DNS zone.


`record_sets`

-   is required
-   Type: `object[]` ([Details](resources-properties-dns_zones-items-properties-record_sets-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-record_sets.md "undefined#/properties/dns_zones/items/properties/record_sets")

### record_sets Type

`object[]` ([Details](resources-properties-dns_zones-items-properties-record_sets-items.md))

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-resource_name.md "undefined#/properties/dns_zones/items/properties/resource_name")

### resource_name Type

`string`

## type

Type of DNS zone.


`type`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones-items-properties-type.md "undefined#/properties/dns_zones/items/properties/type")

### type Type

`string`

### type Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value          | Explanation |
| :------------- | ----------- |
| `"public"`     |             |
| `"private"`    |             |
| `"forwarding"` |             |
| `"peering"`    |             |
