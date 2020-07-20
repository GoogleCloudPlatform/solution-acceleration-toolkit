# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/binary_authorization/properties/admission_whitelist_patterns/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-binary_authorization-properties-admission_whitelist_patterns-items.md))

# undefined Properties

| Property                      | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                     |
| :---------------------------- | -------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name_pattern](#name_pattern) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-binary_authorization-properties-admission_whitelist_patterns-items-properties-name_pattern.md "undefined#/properties/binary_authorization/properties/admission_whitelist_patterns/items/properties/name_pattern") |

## name_pattern

                  An image name pattern to whitelist, in the form registry/path/to/image.
                  This supports a trailing * as a wildcard, but this is allowed only in text after the registry/ part."


`name_pattern`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-binary_authorization-properties-admission_whitelist_patterns-items-properties-name_pattern.md "undefined#/properties/binary_authorization/properties/admission_whitelist_patterns/items/properties/name_pattern")

### name_pattern Type

`string`
