# Untitled object in Org Audit Recipe Schema

```txt
undefined#/properties/logs_bigquery_dataset
```

Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [audit.schema.json\*](audit.schema.json "open original schema") |

## logs_bigquery_dataset Type

`object` ([Details](audit-properties-logs_bigquery_dataset.md))

# undefined Properties

| Property                  | Type     | Required | Nullable       | Defined by                                                                                                                                              |
| :------------------------ | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [dataset_id](#dataset_id) | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-logs_bigquery_dataset-properties-dataset_id.md "undefined#/properties/logs_bigquery_dataset/properties/dataset_id") |

## dataset_id

ID of Bigquery Dataset.


`dataset_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-logs_bigquery_dataset-properties-dataset_id.md "undefined#/properties/logs_bigquery_dataset/properties/dataset_id")

### dataset_id Type

`string`
