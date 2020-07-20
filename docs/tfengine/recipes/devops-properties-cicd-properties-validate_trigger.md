# Untitled object in Devops Recipe Schema

```txt
undefined#/properties/cicd/properties/validate_trigger
```

            Config block for the presubmit validation Cloud Build trigger. If specified, create
            the trigger and grant the Cloud Build Service Account necessary permissions to perform
            the build.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                        |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [devops.schema.json\*](devops.schema.json "open original schema") |

## validate_trigger Type

`object` ([Details](devops-properties-cicd-properties-validate_trigger.md))

# undefined Properties

| Property            | Type      | Required | Nullable       | Defined by                                                                                                                                                            |
| :------------------ | --------- | -------- | -------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [disable](#disable) | `boolean` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-validate_trigger-properties-disable.md "undefined#/properties/cicd/properties/validate_trigger/properties/disable") |

## disable

                Whether or not to disable automatic triggering from a PR/push to branch. Default
                to false.


`disable`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-validate_trigger-properties-disable.md "undefined#/properties/cicd/properties/validate_trigger/properties/disable")

### disable Type

`boolean`
