# Terraform Deployment Recipe. Schema

```txt
undefined
```

This recipe should be used to setup a new Terraform deployment directory.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [deployment.schema.json](deployment.schema.json "open original schema") |

## Terraform Deployment Recipe. Type

unknown ([Terraform Deployment Recipe.](deployment.md))

# Terraform Deployment Recipe. Properties

| Property                                | Type          | Required | Nullable       | Defined by                                                                                                           |
| :-------------------------------------- | ------------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------- |
| [enable_terragrunt](#enable_terragrunt) | Not specified | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-enable_terragrunt.md "undefined#/properties/enable_terragrunt") |
| [state_bucket](#state_bucket)           | `string`      | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-state_bucket.md "undefined#/properties/state_bucket")           |
| [state_path_prefix](#state_path_prefix) | `string`      | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-state_path_prefix.md "undefined#/properties/state_path_prefix") |
| [terraform_addons](#terraform_addons)   | `object`      | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons.md "undefined#/properties/terraform_addons")   |

## enable_terragrunt

Whether to convert to a Terragrunt deployment. Adds a terragrunt.hcl file in the deployment.


`enable_terragrunt`

-   is optional
-   Type: unknown
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-enable_terragrunt.md "undefined#/properties/enable_terragrunt")

### enable_terragrunt Type

unknown

## state_bucket

State bucket to use for GCS backend. Does nothing if 'enable_terragrunt' is true.


`state_bucket`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-state_bucket.md "undefined#/properties/state_bucket")

### state_bucket Type

`string`

## state_path_prefix

Object path prefix for GCS backend. Does nothing if 'enable_terragrunt' is true.


`state_path_prefix`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-state_path_prefix.md "undefined#/properties/state_path_prefix")

### state_path_prefix Type

`string`

## terraform_addons

Extra addons to set in the deployment.


`terraform_addons`

-   is optional
-   Type: `object` ([Details](deployment-properties-terraform_addons.md))
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons.md "undefined#/properties/terraform_addons")

### terraform_addons Type

`object` ([Details](deployment-properties-terraform_addons.md))
