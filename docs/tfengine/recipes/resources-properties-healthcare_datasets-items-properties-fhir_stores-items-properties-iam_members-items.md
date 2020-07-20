# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items.md))

# undefined Properties

| Property          | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                                                           |
| :---------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [member](#member) | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items-properties-member.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members/items/properties/member") |
| [role](#role)     | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items-properties-role.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members/items/properties/role")     |

## member

Member to grant acess to role.


`member`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items-properties-member.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members/items/properties/member")

### member Type

`string`

## role

IAM role to grant.


`role`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items-properties-role.md "undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members/items/properties/role")

### role Type

`string`
