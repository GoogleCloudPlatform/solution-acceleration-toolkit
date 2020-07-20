# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/storage_buckets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                              | Type     | Required | Nullable       | Defined by                                                                                                                                                                                   |
| :------------------------------------ | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [iam_members](#iam_members)           | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-iam_members.md "undefined#/properties/storage_buckets/items/properties/iam_members")           |
| [lifecycle_rules](#lifecycle_rules)   | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules")   |
| [name](#name)                         | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-name.md "undefined#/properties/storage_buckets/items/properties/name")                         |
| [resource_name](#resource_name)       | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-resource_name.md "undefined#/properties/storage_buckets/items/properties/resource_name")       |
| [storage_location](#storage_location) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-storage_location.md "undefined#/properties/storage_buckets/items/properties/storage_location") |

## iam_members

IAM member to grant access for.


`iam_members`

-   is optional
-   Type: `object[]` ([Details](resources-properties-storage_buckets-items-properties-iam_members-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-iam_members.md "undefined#/properties/storage_buckets/items/properties/iam_members")

### iam_members Type

`object[]` ([Details](resources-properties-storage_buckets-items-properties-iam_members-items.md))

## lifecycle_rules

Lifecycle rules configuration for the bucket.


`lifecycle_rules`

-   is optional
-   Type: `object[]` ([Details](resources-properties-storage_buckets-items-properties-lifecycle_rules-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-lifecycle_rules.md "undefined#/properties/storage_buckets/items/properties/lifecycle_rules")

### lifecycle_rules Type

`object[]` ([Details](resources-properties-storage_buckets-items-properties-lifecycle_rules-items.md))

## name

Name of storage bucket.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-name.md "undefined#/properties/storage_buckets/items/properties/name")

### name Type

`string`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-resource_name.md "undefined#/properties/storage_buckets/items/properties/resource_name")

### resource_name Type

`string`

## storage_location

Location to create the storage bucket. Can be defined in global data block.


`storage_location`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets-items-properties-storage_location.md "undefined#/properties/storage_buckets/items/properties/storage_location")

### storage_location Type

`string`
