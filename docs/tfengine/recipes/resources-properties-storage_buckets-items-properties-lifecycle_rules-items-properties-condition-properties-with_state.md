# Untitled string in Recipe for resources within projects. Schema

```txt
undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/with_state
```

Match to live and/or archived objects.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## with_state Type

`string`

## with_state Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value        | Explanation |
| :----------- | ----------- |
| `"LIVE"`     |             |
| `"ARCHIVED"` |             |
| `"ANY"`      |             |
