# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/service_accounts/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                        | Type     | Required | Nullable       | Defined by                                                                                                                                                                               |
| :------------------------------ | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [account_id](#account_id)       | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-service_accounts-items-properties-account_id.md "undefined#/properties/service_accounts/items/properties/account_id")       |
| [resource_name](#resource_name) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-service_accounts-items-properties-resource_name.md "undefined#/properties/service_accounts/items/properties/resource_name") |

## account_id

ID of service account.


`account_id`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-service_accounts-items-properties-account_id.md "undefined#/properties/service_accounts/items/properties/account_id")

### account_id Type

`string`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized account_id.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-service_accounts-items-properties-resource_name.md "undefined#/properties/service_accounts/items/properties/resource_name")

### resource_name Type

`string`
