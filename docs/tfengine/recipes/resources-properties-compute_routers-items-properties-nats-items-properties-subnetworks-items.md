# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items.md))

# undefined Properties

| Property                                              | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                                                         |
| :---------------------------------------------------- | -------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)                                         | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-name.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/name")                                         |
| [secondary_ip_range_names](#secondary_ip_range_names) | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-secondary_ip_range_names.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/secondary_ip_range_names") |
| [source_ip_ranges_to_nat](#source_ip_ranges_to_nat)   | `array`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-source_ip_ranges_to_nat.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/source_ip_ranges_to_nat")   |

## name

Name of subnet.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-name.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/name")

### name Type

`string`

## secondary_ip_range_names

List of the secondary ranges of the subnetwork that are allowed to use NAT. Only applicable if one of the values in 'source_ip_ranges_to_nat' is 'LIST_OF_SECONDARY_IP_RANGES'.


`secondary_ip_range_names`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-secondary_ip_range_names.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/secondary_ip_range_names")

### secondary_ip_range_names Type

`string[]`

## source_ip_ranges_to_nat

List of options for which source IPs in the subnetwork should have NAT enabled.


`source_ip_ranges_to_nat`

-   is required
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-source_ip_ranges_to_nat.md "undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/source_ip_ranges_to_nat")

### source_ip_ranges_to_nat Type

`string[]`
