# Untitled object in Terraform Deployment Recipe. Schema

```txt
undefined#/properties/terraform_addons/properties/deps/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [deployment.schema.json\*](deployment.schema.json "open original schema") |

## items Type

`object` ([Details](deployment-properties-terraform_addons-properties-deps-items.md))

# undefined Properties

| Property                      | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                     |
| :---------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [mock_outputs](#mock_outputs) | `object` | Optional | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps-items-properties-mock_outputs.md "undefined#/properties/terraform_addons/properties/deps/items/properties/mock_outputs") |
| [name](#name)                 | `string` | Required | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps-items-properties-name.md "undefined#/properties/terraform_addons/properties/deps/items/properties/name")                 |
| [path](#path)                 | `string` | Required | cannot be null | [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps-items-properties-path.md "undefined#/properties/terraform_addons/properties/deps/items/properties/path")                 |

## mock_outputs

Mock outputs for the deployment to add.


`mock_outputs`

-   is optional
-   Type: `object` ([Details](deployment-properties-terraform_addons-properties-deps-items-properties-mock_outputs.md))
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps-items-properties-mock_outputs.md "undefined#/properties/terraform_addons/properties/deps/items/properties/mock_outputs")

### mock_outputs Type

`object` ([Details](deployment-properties-terraform_addons-properties-deps-items-properties-mock_outputs.md))

## name

Name of dependency.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps-items-properties-name.md "undefined#/properties/terraform_addons/properties/deps/items/properties/name")

### name Type

`string`

## path

Path to deployment.


`path`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Terraform Deployment Recipe.](deployment-properties-terraform_addons-properties-deps-items-properties-path.md "undefined#/properties/terraform_addons/properties/deps/items/properties/path")

### path Type

`string`
