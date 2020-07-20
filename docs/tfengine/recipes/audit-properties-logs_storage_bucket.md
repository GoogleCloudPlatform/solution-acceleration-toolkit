# Untitled object in Org Audit Recipe Schema

```txt
undefined#/properties/logs_storage_bucket
```

GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [audit.schema.json\*](audit.schema.json "open original schema") |

## logs_storage_bucket Type

`object` ([Details](audit-properties-logs_storage_bucket.md))

# undefined Properties

| Property      | Type     | Required | Nullable       | Defined by                                                                                                                              |
| :------------ | -------- | -------- | -------------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name) | `string` | Optional | cannot be null | [Org Audit Recipe](audit-properties-logs_storage_bucket-properties-name.md "undefined#/properties/logs_storage_bucket/properties/name") |

## name

Name of GCS bucket.


`name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Audit Recipe](audit-properties-logs_storage_bucket-properties-name.md "undefined#/properties/logs_storage_bucket/properties/name")

### name Type

`string`
