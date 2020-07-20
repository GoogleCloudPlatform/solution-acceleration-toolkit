# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/binary_authorization
```

A policy for container image binary authorization.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## binary_authorization Type

`object` ([Details](resources-properties-binary_authorization.md))

# undefined Properties

| Property                                                      | Type    | Required | Nullable       | Defined by                                                                                                                                                                                                         |
| :------------------------------------------------------------ | ------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [admission_whitelist_patterns](#admission_whitelist_patterns) | `array` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-binary_authorization-properties-admission_whitelist_patterns.md "undefined#/properties/binary_authorization/properties/admission_whitelist_patterns") |

## admission_whitelist_patterns

A whitelist of image patterns to exclude from admission rules.


`admission_whitelist_patterns`

-   is optional
-   Type: `object[]` ([Details](resources-properties-binary_authorization-properties-admission_whitelist_patterns-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-binary_authorization-properties-admission_whitelist_patterns.md "undefined#/properties/binary_authorization/properties/admission_whitelist_patterns")

### admission_whitelist_patterns Type

`object[]` ([Details](resources-properties-binary_authorization-properties-admission_whitelist_patterns-items.md))
