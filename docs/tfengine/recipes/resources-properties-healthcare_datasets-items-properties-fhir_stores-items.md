# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-healthcare_datasets-items-properties-fhir_stores-items.md))

# undefined Properties

| Property                    | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                           |
| :-------------------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [iam_members](#iam_members) | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members") |
| [name](#name)               | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-name.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/name")               |
| [version](#version)         | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-version.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/version")         |

## iam_members

IAM member to grant access for.


`iam_members`

-   is optional
-   Type: `object[]` ([Details](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members")

### iam_members Type

`object[]` ([Details](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items.md))

## name

Name of FHIR store.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-name.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/name")

### name Type

`string`

## version

Version of FHIR store.


`version`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-version.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/version")

### version Type

`string`
