# Devops Recipe Schema

```txt
undefined
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [devops.schema.json](devops.schema.json "open original schema") |

## Devops Recipe Type

unknown ([Devops Recipe](devops.md))

# Devops Recipe Properties

| Property                                                      | Type      | Required | Nullable       | Defined by                                                                                                              |
| :------------------------------------------------------------ | --------- | -------- | -------------- | :---------------------------------------------------------------------------------------------------------------------- |
| [admins_group](#admins_group)                                 | `string`  | Optional | cannot be null | [Devops Recipe](devops-properties-admins_group.md "undefined#/properties/admins_group")                                 |
| [billing_account](#billing_account)                           | `string`  | Optional | cannot be null | [Devops Recipe](devops-properties-billing_account.md "undefined#/properties/billing_account")                           |
| [cicd](#cicd)                                                 | `object`  | Optional | cannot be null | [Devops Recipe](devops-properties-cicd.md "undefined#/properties/cicd")                                                 |
| [enable_bootstrap_gcs_backend](#enable_bootstrap_gcs_backend) | `boolean` | Optional | cannot be null | [Devops Recipe](devops-properties-enable_bootstrap_gcs_backend.md "undefined#/properties/enable_bootstrap_gcs_backend") |
| [enable_terragrunt](#enable_terragrunt)                       | `boolean` | Optional | cannot be null | [Devops Recipe](devops-properties-enable_terragrunt.md "undefined#/properties/enable_terragrunt")                       |
| [parent_id](#parent_id)                                       | `string`  | Optional | cannot be null | [Devops Recipe](devops-properties-parent_id.md "undefined#/properties/parent_id")                                       |
| [parent_type](#parent_type)                                   | `string`  | Optional | cannot be null | [Devops Recipe](devops-properties-parent_type.md "undefined#/properties/parent_type")                                   |
| [project](#project)                                           | `object`  | Optional | cannot be null | [Devops Recipe](devops-properties-project.md "undefined#/properties/project")                                           |
| [state_bucket](#state_bucket)                                 | `string`  | Optional | cannot be null | [Devops Recipe](devops-properties-state_bucket.md "undefined#/properties/state_bucket")                                 |
| [storage_location](#storage_location)                         | `string`  | Optional | cannot be null | [Devops Recipe](devops-properties-storage_location.md "undefined#/properties/storage_location")                         |

## admins_group

Group who will be given org admin access.


`admins_group`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-admins_group.md "undefined#/properties/admins_group")

### admins_group Type

`string`

## billing_account

ID of billing account to attach to this project.


`billing_account`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-billing_account.md "undefined#/properties/billing_account")

### billing_account Type

`string`

## cicd

Config for CICD. If unset there will be no CICD.


`cicd`

-   is optional
-   Type: `object` ([Details](devops-properties-cicd.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd.md "undefined#/properties/cicd")

### cicd Type

`object` ([Details](devops-properties-cicd.md))

## enable_bootstrap_gcs_backend

        Whether to enable GCS backend for the bootstrap deployment. Defaults to false.
        Since the bootstrap deployment creates the state bucket, it cannot back the state
        to the GCS bucket on the first deployment. Thus, this field should be set to true
        after the bootstrap deployment has been applied. Then the user can run `terraform init`
        in the bootstrapd deployment to transfer the state from local to GCS.


`enable_bootstrap_gcs_backend`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-enable_bootstrap_gcs_backend.md "undefined#/properties/enable_bootstrap_gcs_backend")

### enable_bootstrap_gcs_backend Type

`boolean`

## enable_terragrunt

        Whether to convert to a Terragrunt deployment. If set to "false", generate Terraform-only
        configs and the CICD pipelines will only use Terraform. Default to "true".


`enable_terragrunt`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-enable_terragrunt.md "undefined#/properties/enable_terragrunt")

### enable_terragrunt Type

`boolean`

## parent_id

        ID of parent GCP resource to apply the policy: can be one of the organization ID,
        folder ID according to parent_type.


`parent_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-parent_id.md "undefined#/properties/parent_id")

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
-   defined in: [Devops Recipe](devops-properties-parent_type.md "undefined#/properties/parent_type")

### parent_type Type

`string`

### parent_type Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^organization|folder$
```

[try pattern](https://regexr.com/?expression=%5Eorganization%7Cfolder%24 "try regular expression with regexr.com")

## project

Config for the project to host devops related resources such as state bucket and CICD.


`project`

-   is optional
-   Type: `object` ([Details](devops-properties-project.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-project.md "undefined#/properties/project")

### project Type

`object` ([Details](devops-properties-project.md))

## state_bucket

Name of Terraform remote state bucket.


`state_bucket`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-state_bucket.md "undefined#/properties/state_bucket")

### state_bucket Type

`string`

## storage_location

Location of state bucket.


`storage_location`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-storage_location.md "undefined#/properties/storage_location")

### storage_location Type

`string`
