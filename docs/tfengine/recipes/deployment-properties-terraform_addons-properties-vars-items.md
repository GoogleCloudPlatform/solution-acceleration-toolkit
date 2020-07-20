# Untitled object in Terraform Deployment Recipe. Schema

```txt
undefined#/properties/terraform_addons/properties/vars/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [deployment.schema.json\*](deployment.schema.json "open original schema") |

## items Type

`object` ([Details](deployment-properties-terraform_addons-properties-vars-items.md))

# undefined Properties

| Property                              | Type          | Required | Nullable       | Defined by                                                                                                                                                                                                             |
| :------------------------------------ | ------------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [default](#default)                   | Not specified | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-default.md "undefined#/properties/terraform_addons/properties/vars/items/properties/default")                   |
| [name](#name)                         | `string`      | Required | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-name.md "undefined#/properties/terraform_addons/properties/vars/items/properties/name")                         |
| [terragrunt_input](#terragrunt_input) | Not specified | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-terragrunt_input.md "undefined#/properties/terraform_addons/properties/vars/items/properties/terragrunt_input") |
| [type](#type)                         | `string`      | Required | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-type.md "undefined#/properties/terraform_addons/properties/vars/items/properties/type")                         |
| [value](#value)                       | Not specified | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-value.md "undefined#/properties/terraform_addons/properties/vars/items/properties/value")                       |

## default

Default value of variable.


`default`

-   is optional
-   Type: unknown
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-default.md "undefined#/properties/terraform_addons/properties/vars/items/properties/default")

### default Type

unknown

## name

Name of the variable.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-name.md "undefined#/properties/terraform_addons/properties/vars/items/properties/name")

### name Type

`string`

## terragrunt_input

Input value to set in terragrunt.hcl for this var.


`terragrunt_input`

-   is optional
-   Type: unknown
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-terragrunt_input.md "undefined#/properties/terraform_addons/properties/vars/items/properties/terragrunt_input")

### terragrunt_input Type

unknown

## type

Type of variable.


`type`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-type.md "undefined#/properties/terraform_addons/properties/vars/items/properties/type")

### type Type

`string`

## value

Value of variable to set in terraform.tfvars.


`value`

-   is optional
-   Type: unknown
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars-items-properties-value.md "undefined#/properties/terraform_addons/properties/vars/items/properties/value")

### value Type

unknown
