# Untitled string in Recipe for resources within projects. Schema

```txt
undefined#/properties/dns_zones/items/properties/domain
```

Domain of DNS zone. Must end with period.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## domain Type

`string`

## domain Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^.+\.$
```

[try pattern](https://regexr.com/?expression=%5E.%2B%5C.%24 "try regular expression with regexr.com")
