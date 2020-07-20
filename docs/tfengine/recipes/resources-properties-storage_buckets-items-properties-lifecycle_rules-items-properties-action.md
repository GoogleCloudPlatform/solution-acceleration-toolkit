# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/action
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## action Type

`object` ([Details](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-action.md))

# undefined Properties

| Property                        | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                                   |
| :------------------------------ | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [storage_class](#storage_class) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-action-properties-storage_class.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/action/properties/storage_class") |
| [type](#type)                   | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-action-properties-type.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/action/properties/type")                   |

## storage_class

(Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.


`storage_class`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-action-properties-storage_class.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/action/properties/storage_class")

### storage_class Type

`string`

## type

Type of action. Supported values: Delete and SetStorageClass.


`type`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-action-properties-type.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/action/properties/type")

### type Type

`string`
