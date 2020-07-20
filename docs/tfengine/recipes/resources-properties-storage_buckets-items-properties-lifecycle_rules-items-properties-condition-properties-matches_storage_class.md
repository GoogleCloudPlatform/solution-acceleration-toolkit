# Untitled string in Recipe for resources within projects. Schema

```txt
undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/matches_storage_class
```

Storage Class of objects to satisfy this condition.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## matches_storage_class Type

`string`

## matches_storage_class Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value                            | Explanation |
| :------------------------------- | ----------- |
| `"STANDARD"`                     |             |
| `"MULTI_REGIONAL"`               |             |
| `"REGIONAL"`                     |             |
| `"NEARLINE"`                     |             |
| `"COLDLINE"`                     |             |
| `"DURABLE_REDUCED_AVAILABILITY"` |             |
