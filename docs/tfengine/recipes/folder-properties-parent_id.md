# Untitled string in Recipe for creating GCP folders. Schema

```txt
undefined#/properties/parent_id
```

        ID of parent GCP resource to apply the policy: can be one of the organization ID or folder ID according to parent_type.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                    |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [folder.schema.json\*](../../../../../../../../../../tmp/182028425/folder.schema.json "open original schema") |

## parent_id Type

`string`

## parent_id Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^[0-9]{8,25}$
```

[try pattern](https://regexr.com/?expression=%5E%5B0-9%5D%7B8%2C25%7D%24 "try regular expression with regexr.com")
