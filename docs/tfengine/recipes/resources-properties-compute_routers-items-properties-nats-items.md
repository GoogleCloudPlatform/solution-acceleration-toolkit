# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_routers/items/properties/nats/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-compute_routers-items-properties-nats-items.md))

# undefined Properties

| Property                                                                  | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                   |
| :------------------------------------------------------------------------ | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)                                                             | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-name.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/name")                                                             |
| [source_subnetwork_ip_ranges_to_nat](#source_subnetwork_ip_ranges_to_nat) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-source_subnetwork_ip_ranges_to_nat.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/source_subnetwork_ip_ranges_to_nat") |
| [subnetworks](#subnetworks)                                               | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks")                                               |

## name

Name of NAT.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-name.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/name")

### name Type

`string`

## source_subnetwork_ip_ranges_to_nat

How NAT should be configured per Subnetwork.


`source_subnetwork_ip_ranges_to_nat`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-source_subnetwork_ip_ranges_to_nat.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/source_subnetwork_ip_ranges_to_nat")

### source_subnetwork_ip_ranges_to_nat Type

`string`

## subnetworks

Subnet NAT configurations. Only applicable if 'source_subnetwork_ip_ranges_to_nat' is 'LIST_OF_SUBNETWORKS'.


`subnetworks`

-   is optional
-   Type: `object[]` ([Details](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks")

### subnetworks Type

`object[]` ([Details](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items.md))
