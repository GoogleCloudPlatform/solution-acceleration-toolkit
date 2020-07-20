# Untitled string in Recipe for creating GCP folders. Schema

```txt
undefined#/properties/parent_type
```

Type of parent GCP resource to apply the policy: can be one of 'organization' or 'folder'.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                        |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [folder.schema.json\*](folder.schema.json "open original schema") |

## parent_type Type

`string`

## parent_type Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^organization|folder$
```

[try pattern](https://regexr.com/?expression=%5Eorganization%7Cfolder%24 "try regular expression with regexr.com")
