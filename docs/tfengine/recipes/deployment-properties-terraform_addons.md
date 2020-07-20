# Untitled object in Terraform Deployment Recipe. Schema

```txt
undefined#/properties/terraform_addons
```

Extra addons to set in the deployment.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                            |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [deployment.schema.json\*](../../../../../../../../../../tmp/182028425/deployment.schema.json "open original schema") |

## terraform_addons Type

`object` ([Details](deployment-properties-terraform_addons.md))

# undefined Properties

| Property                  | Type     | Required | Nullable       | Defined by                                                                                                                                                     |
| :------------------------ | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [deps](#deps)             | `array`  | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps.md "undefined#/properties/terraform_addons/properties/deps")             |
| [inputs](#inputs)         | `object` | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-inputs.md "undefined#/properties/terraform_addons/properties/inputs")         |
| [outputs](#outputs)       | `array`  | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-outputs.md "undefined#/properties/terraform_addons/properties/outputs")       |
| [raw_config](#raw_config) | `string` | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-raw_config.md "undefined#/properties/terraform_addons/properties/raw_config") |
| [vars](#vars)             | `array`  | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars.md "undefined#/properties/terraform_addons/properties/vars")             |

## deps

Additional dependencies on other deployments.


`deps`

-   is optional
-   Type: `object[]` ([Details](deployment-properties-terraform_addons-properties-deps-items.md))
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps.md "undefined#/properties/terraform_addons/properties/deps")

### deps Type

`object[]` ([Details](deployment-properties-terraform_addons-properties-deps-items.md))

## inputs

Additional inputs to be set in terraform.tfvars


`inputs`

-   is optional
-   Type: `object` ([Details](deployment-properties-terraform_addons-properties-inputs.md))
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-inputs.md "undefined#/properties/terraform_addons/properties/inputs")

### inputs Type

`object` ([Details](deployment-properties-terraform_addons-properties-inputs.md))

## outputs

Additional outputs to set in outputs.tf.


`outputs`

-   is optional
-   Type: `object[]` ([Details](deployment-properties-terraform_addons-properties-outputs-items.md))
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-outputs.md "undefined#/properties/terraform_addons/properties/outputs")

### outputs Type

`object[]` ([Details](deployment-properties-terraform_addons-properties-outputs-items.md))

## raw_config

            Raw text to insert in the Terraform main.tf file.
            Can be used to add arbitrary blocks or resources that the engine does not support.


`raw_config`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-raw_config.md "undefined#/properties/terraform_addons/properties/raw_config")

### raw_config Type

`string`

## vars

Additional vars to set in the deployment in variables.tf.


`vars`

-   is optional
-   Type: `object[]` ([Details](deployment-properties-terraform_addons-properties-vars-items.md))
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-vars.md "undefined#/properties/terraform_addons/properties/vars")

### vars Type

`object[]` ([Details](deployment-properties-terraform_addons-properties-vars-items.md))
