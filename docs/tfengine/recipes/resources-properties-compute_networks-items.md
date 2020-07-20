# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_networks/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                        | Type     | Required | Nullable       | Defined by                                                                                                                                                                               |
| :------------------------------ | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)                   | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-name.md "undefined#/properties/compute_networks/items/properties/name")                   |
| [resource_name](#resource_name) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-resource_name.md "undefined#/properties/compute_networks/items/properties/resource_name") |
| [subnets](#subnets)             | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets.md "undefined#/properties/compute_networks/items/properties/subnets")             |

## name

Name of network.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-name.md "undefined#/properties/compute_networks/items/properties/name")

### name Type

`string`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-resource_name.md "undefined#/properties/compute_networks/items/properties/resource_name")

### resource_name Type

`string`

## subnets

Subnetworks within the network.


`subnets`

-   is optional
-   Type: `object[]` ([Details](resources-properties-compute_networks-items-properties-subnets-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks-items-properties-subnets.md "undefined#/properties/compute_networks/items/properties/subnets")

### subnets Type

`object[]` ([Details](resources-properties-compute_networks-items-properties-subnets-items.md))
