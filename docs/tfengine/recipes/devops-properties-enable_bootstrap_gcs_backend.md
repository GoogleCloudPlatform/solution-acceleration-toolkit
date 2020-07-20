# Untitled boolean in Devops Recipe Schema

```txt
undefined#/properties/enable_bootstrap_gcs_backend
```

        Whether to enable GCS backend for the bootstrap deployment. Defaults to false.
        Since the bootstrap deployment creates the state bucket, it cannot back the state
        to the GCS bucket on the first deployment. Thus, this field should be set to true
        after the bootstrap deployment has been applied. Then the user can run `terraform init`
        in the bootstrapd deployment to transfer the state from local to GCS.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                        |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [devops.schema.json\*](devops.schema.json "open original schema") |

## enable_bootstrap_gcs_backend Type

`boolean`
