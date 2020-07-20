# Untitled string in Recipe for resources within projects. Schema

```txt
undefined#/properties/cloud_sql_instances/items/properties/type
```

Type of the cloud sql instance. Currently only supports 'mysql'.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## type Type

`string`

## type Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^mysql$
```

[try pattern](https://regexr.com/?expression=%5Emysql%24 "try regular expression with regexr.com")
