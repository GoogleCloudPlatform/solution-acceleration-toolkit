# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/secrets/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                        | Type     | Required | Nullable       | Defined by                                                                                                                                                             |
| :------------------------------ | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [locations](#locations)         | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-secrets-items-properties-locations.md "undefined#/properties/secrets/items/properties/locations")         |
| [resource_name](#resource_name) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-secrets-items-properties-resource_name.md "undefined#/properties/secrets/items/properties/resource_name") |
| [secret_data](#secret_data)     | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-secrets-items-properties-secret_data.md "undefined#/properties/secrets/items/properties/secret_data")     |
| [secret_id](#secret_id)         | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-secrets-items-properties-secret_id.md "undefined#/properties/secrets/items/properties/secret_id")         |

## locations

Locations to replicate secret. If unset, will automatically replicate.


`locations`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-secrets-items-properties-locations.md "undefined#/properties/secrets/items/properties/locations")

### locations Type

`string[]`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized secret_id.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-secrets-items-properties-resource_name.md "undefined#/properties/secrets/items/properties/resource_name")

### resource_name Type

`string`

## secret_data

Data of the secret. If unset, should be manually set in the GCP console.


`secret_data`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-secrets-items-properties-secret_data.md "undefined#/properties/secrets/items/properties/secret_data")

### secret_data Type

`string`

## secret_id

ID of secret.


`secret_id`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-secrets-items-properties-secret_id.md "undefined#/properties/secrets/items/properties/secret_id")

### secret_id Type

`string`
