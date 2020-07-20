# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/healthcare_datasets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                                | Type     | Required | Nullable       | Defined by                                                                                                                                                                                             |
| :-------------------------------------- | -------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [dicom_stores](#dicom_stores)           | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-dicom_stores.md "undefined#/properties/healthcare_datasets/items/properties/dicom_stores")           |
| [fhir_stores](#fhir_stores)             | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores")             |
| [healthcare_region](#healthcare_region) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-healthcare_region.md "undefined#/properties/healthcare_datasets/items/properties/healthcare_region") |
| [hl7_v2_stores](#hl7_v2_stores)         | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-hl7_v2_stores.md "undefined#/properties/healthcare_datasets/items/properties/hl7_v2_stores")         |
| [iam_members](#iam_members)             | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-iam_members.md "undefined#/properties/healthcare_datasets/items/properties/iam_members")             |
| [name](#name)                           | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-name.md "undefined#/properties/healthcare_datasets/items/properties/name")                           |

## dicom_stores

Dicom stores to create.


`dicom_stores`

-   is optional
-   Type: `object[]` ([Details](resources-properties-healthcare_datasets-items-properties-dicom_stores-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-dicom_stores.md "undefined#/properties/healthcare_datasets/items/properties/dicom_stores")

### dicom_stores Type

`object[]` ([Details](resources-properties-healthcare_datasets-items-properties-dicom_stores-items.md))

## fhir_stores

FHIR stores to create.


`fhir_stores`

-   is optional
-   Type: `object[]` ([Details](resources-properties-healthcare_datasets-items-properties-fhir_stores-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores")

### fhir_stores Type

`object[]` ([Details](resources-properties-healthcare_datasets-items-properties-fhir_stores-items.md))

## healthcare_region

Region to create healthcare dataset in. Can be defined in global data block.


`healthcare_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-healthcare_region.md "undefined#/properties/healthcare_datasets/items/properties/healthcare_region")

### healthcare_region Type

`string`

## hl7_v2_stores

HL7 V2 stores to create.


`hl7_v2_stores`

-   is optional
-   Type: `object[]` ([Details](resources-properties-healthcare_datasets-items-properties-hl7_v2_stores-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-hl7_v2_stores.md "undefined#/properties/healthcare_datasets/items/properties/hl7_v2_stores")

### hl7_v2_stores Type

`object[]` ([Details](resources-properties-healthcare_datasets-items-properties-hl7_v2_stores-items.md))

## iam_members

IAM member to grant access for.


`iam_members`

-   is optional
-   Type: `object[]` ([Details](resources-properties-healthcare_datasets-items-properties-iam_members-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-iam_members.md "undefined#/properties/healthcare_datasets/items/properties/iam_members")

### iam_members Type

`object[]` ([Details](resources-properties-healthcare_datasets-items-properties-iam_members-items.md))

## name

Name of healthcare dataset.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-name.md "undefined#/properties/healthcare_datasets/items/properties/name")

### name Type

`string`
