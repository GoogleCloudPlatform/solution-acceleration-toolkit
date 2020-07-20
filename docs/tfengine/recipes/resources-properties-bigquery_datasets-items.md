# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/bigquery_datasets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-bigquery_datasets-items.md))

# undefined Properties

| Property                                                    | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                             |
| :---------------------------------------------------------- | --------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [access](#access)                                           | `array`   | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access.md "undefined#/properties/bigquery_datasets/items/properties/access")                                           |
| [bigquery_location](#bigquery_location)                     | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-bigquery_location.md "undefined#/properties/bigquery_datasets/items/properties/bigquery_location")                     |
| [dataset_id](#dataset_id)                                   | `string`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-dataset_id.md "undefined#/properties/bigquery_datasets/items/properties/dataset_id")                                   |
| [default_table_expiration_ms](#default_table_expiration_ms) | `integer` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-default_table_expiration_ms.md "undefined#/properties/bigquery_datasets/items/properties/default_table_expiration_ms") |
| [resource_name](#resource_name)                             | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-resource_name.md "undefined#/properties/bigquery_datasets/items/properties/resource_name")                             |

## access

              Access for this bigquery dataset.
              Each object should contain exactly one of the following keys:
              - group_by_email
              - user_by_email
              - special_group


`access`

-   is optional
-   Type: `object[]` ([Details](resources-properties-bigquery_datasets-items-properties-access-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access.md "undefined#/properties/bigquery_datasets/items/properties/access")

### access Type

`object[]` ([Details](resources-properties-bigquery_datasets-items-properties-access-items.md))

## bigquery_location

Location to create the bigquery dataset. Can be defined in global data block.


`bigquery_location`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-bigquery_location.md "undefined#/properties/bigquery_datasets/items/properties/bigquery_location")

### bigquery_location Type

`string`

## dataset_id

ID of bigquery dataset.


`dataset_id`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-dataset_id.md "undefined#/properties/bigquery_datasets/items/properties/dataset_id")

### dataset_id Type

`string`

## default_table_expiration_ms

Expiration in milliseconds.


`default_table_expiration_ms`

-   is optional
-   Type: `integer`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-default_table_expiration_ms.md "undefined#/properties/bigquery_datasets/items/properties/default_table_expiration_ms")

### default_table_expiration_ms Type

`integer`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized dataset_id.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-resource_name.md "undefined#/properties/bigquery_datasets/items/properties/resource_name")

### resource_name Type

`string`
