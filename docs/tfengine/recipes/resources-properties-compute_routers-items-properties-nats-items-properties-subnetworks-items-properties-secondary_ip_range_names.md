# Untitled array in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/secondary_ip_range_names
```

List of the secondary ranges of the subnetwork that are allowed to use NAT. Only applicable if one of the values in 'source_ip_ranges_to_nat' is 'LIST_OF_SECONDARY_IP_RANGES'.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## secondary_ip_range_names Type

`string[]`
