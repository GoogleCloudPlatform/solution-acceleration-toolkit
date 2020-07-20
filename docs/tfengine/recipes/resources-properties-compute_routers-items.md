# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_routers/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                          | Type     | Required | Nullable       | Defined by                                                                                                                                                                               |
| :-------------------------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [compute_region](#compute_region) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-compute_region.md "undefined#/properties/compute_routers/items/properties/compute_region") |
| [name](#name)                     | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-name.md "undefined#/properties/compute_routers/items/properties/name")                     |
| [nats](#nats)                     | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats.md "undefined#/properties/compute_routers/items/properties/nats")                     |
| [network](#network)               | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-network.md "undefined#/properties/compute_routers/items/properties/network")               |
| [resource_name](#resource_name)   | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-resource_name.md "undefined#/properties/compute_routers/items/properties/resource_name")   |

## compute_region

Region to create subnet in. Can be defined in global data block.


`compute_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-compute_region.md "undefined#/properties/compute_routers/items/properties/compute_region")

### compute_region Type

`string`

## name

Name of router.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-name.md "undefined#/properties/compute_routers/items/properties/name")

### name Type

`string`

## nats

NATs to attach to the router.


`nats`

-   is optional
-   Type: `object[]` ([Details](resources-properties-compute_routers-items-properties-nats-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats.md "undefined#/properties/compute_routers/items/properties/nats")

### nats Type

`object[]` ([Details](resources-properties-compute_routers-items-properties-nats-items.md))

## network

Name of network the router belongs to.


`network`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-network.md "undefined#/properties/compute_routers/items/properties/network")

### network Type

`string`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-resource_name.md "undefined#/properties/compute_routers/items/properties/resource_name")

### resource_name Type

`string`
