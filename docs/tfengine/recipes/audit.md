# Org Audit Recipe Schema

```txt
undefined
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [audit.schema.json](../../../../../../../../../../tmp/182028425/audit.schema.json "open original schema") |

## Org Audit Recipe Type

unknown ([Org Audit Recipe](audit.md))

# Org Audit Recipe Properties

| Property                                        | Type     | Required | Nullable       | Defined by                                                                                                  |
| :---------------------------------------------- | -------- | -------- | -------------- | :---------------------------------------------------------------------------------------------------------- |
| [auditors_group](#auditors_group)               | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-auditors_group.md "undefined#/properties/auditors_group")               |
| [bigquery_location](#bigquery_location)         | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-bigquery_location.md "undefined#/properties/bigquery_location")         |
| [logs_bigquery_dataset](#logs_bigquery_dataset) | `object` | Optional | cannot be null | [Org Audit Recipe](audit-properties-logs_bigquery_dataset.md "undefined#/properties/logs_bigquery_dataset") |
| [logs_storage_bucket](#logs_storage_bucket)     | `object` | Optional | cannot be null | [Org Audit Recipe](audit-properties-logs_storage_bucket.md "undefined#/properties/logs_storage_bucket")     |
| [parent_id](#parent_id)                         | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-parent_id.md "undefined#/properties/parent_id")                         |
| [parent_type](#parent_type)                     | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-parent_type.md "undefined#/properties/parent_type")                     |
| [project](#project)                             | `object` | Optional | cannot be null | [Org Audit Recipe](audit-properties-project.md "undefined#/properties/project")                             |
| [storage_location](#storage_location)           | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-storage_location.md "undefined#/properties/storage_location")           |

## auditors_group

        This group will be granted viewer access to the audit log dataset and
        bucket as well as security reviewer permission on the root resource
        specified.


`auditors_group`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-auditors_group.md "undefined#/properties/auditors_group")

### auditors_group Type

`string`

## bigquery_location

Location of logs bigquery dataset.


`bigquery_location`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-bigquery_location.md "undefined#/properties/bigquery_location")

### bigquery_location Type

`string`

## logs_bigquery_dataset

Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity.


`logs_bigquery_dataset`

-   is optional
-   Type: `object` ([Details](audit-properties-logs_bigquery_dataset.md))
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-logs_bigquery_dataset.md "undefined#/properties/logs_bigquery_dataset")

### logs_bigquery_dataset Type

`object` ([Details](audit-properties-logs_bigquery_dataset.md))

## logs_storage_bucket

GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements.


`logs_storage_bucket`

-   is optional
-   Type: `object` ([Details](audit-properties-logs_storage_bucket.md))
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-logs_storage_bucket.md "undefined#/properties/logs_storage_bucket")

### logs_storage_bucket Type

`object` ([Details](audit-properties-logs_storage_bucket.md))

## parent_id

        ID of parent GCP resource to apply the policy: can be one of the organization ID,
        folder ID according to parent_type.


`parent_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-parent_id.md "undefined#/properties/parent_id")

### parent_id Type

`string`

### parent_id Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^[0-9]{8,25}$
```

[try pattern](https://regexr.com/?expression=%5E%5B0-9%5D%7B8%2C25%7D%24 "try regular expression with regexr.com")

## parent_type

Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'.


`parent_type`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-parent_type.md "undefined#/properties/parent_type")

### parent_type Type

`string`

### parent_type Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^organization|folder$
```

[try pattern](https://regexr.com/?expression=%5Eorganization%7Cfolder%24 "try regular expression with regexr.com")

## project

Config of project to host auditing resources


`project`

-   is optional
-   Type: `object` ([Details](audit-properties-project.md))
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-project.md "undefined#/properties/project")

### project Type

`object` ([Details](audit-properties-project.md))

## storage_location

Location of logs storage bucket.


`storage_location`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-storage_location.md "undefined#/properties/storage_location")

### storage_location Type

`string`
