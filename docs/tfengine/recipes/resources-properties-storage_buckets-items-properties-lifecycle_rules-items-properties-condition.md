# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## condition Type

`object` ([Details](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition.md))

# undefined Properties

| Property                                        | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                                                         |
| :---------------------------------------------- | --------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [age](#age)                                     | `integer` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-age.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/age")                                     |
| [created_before](#created_before)               | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-created_before.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/created_before")               |
| [matches_storage_class](#matches_storage_class) | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-matches_storage_class.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/matches_storage_class") |
| [num_newer_versions](#num_newer_versions)       | `integer` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-num_newer_versions.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/num_newer_versions")       |
| [with_state](#with_state)                       | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-with_state.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/with_state")                       |

## age

Minimum age of an object in days to satisfy this condition.


`age`

-   is optional
-   Type: `integer`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-age.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/age")

### age Type

`integer`

## created_before

Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.


`created_before`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-created_before.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/created_before")

### created_before Type

`string`

## matches_storage_class

Storage Class of objects to satisfy this condition.


`matches_storage_class`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-matches_storage_class.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/matches_storage_class")

### matches_storage_class Type

`string`

### matches_storage_class Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value                            | Explanation |
| :------------------------------- | ----------- |
| `"STANDARD"`                     |             |
| `"MULTI_REGIONAL"`               |             |
| `"REGIONAL"`                     |             |
| `"NEARLINE"`                     |             |
| `"COLDLINE"`                     |             |
| `"DURABLE_REDUCED_AVAILABILITY"` |             |

## num_newer_versions

Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.


`num_newer_versions`

-   is optional
-   Type: `integer`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-num_newer_versions.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/num_newer_versions")

### num_newer_versions Type

`integer`

## with_state

Match to live and/or archived objects.


`with_state`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition-properties-with_state.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition/properties/with_state")

### with_state Type

`string`

### with_state Constraints

**enum**: the value of this property must be equal to one of the following values:

| Value        | Explanation |
| :----------- | ----------- |
| `"LIVE"`     |             |
| `"ARCHIVED"` |             |
| `"ANY"`      |             |
