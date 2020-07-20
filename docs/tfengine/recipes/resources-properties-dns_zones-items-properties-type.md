# Untitled string in Recipe for resources within projects. Schema

```txt
undefined#/properties/dns_zones/items/properties/type
```

Type of DNS zone.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## type Type

`string`

## type Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value          | Explanation |
| :------------- | ----------- |
| `"public"`     |             |
| `"private"`    |             |
| `"forwarding"` |             |
| `"peering"`    |             |
