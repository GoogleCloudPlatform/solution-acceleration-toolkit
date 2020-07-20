# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_instance_templates/items/properties/instances/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-compute_instance_templates-items-properties-instances-items.md))

# undefined Properties

| Property                        | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                         |
| :------------------------------ | -------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)                   | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-instances-items-properties-name.md "undefined#/properties/compute_instance_templates/items/properties/instances/items/properties/name")                   |
| [resource_name](#resource_name) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-instances-items-properties-resource_name.md "undefined#/properties/compute_instance_templates/items/properties/instances/items/properties/resource_name") |

## name

Name of instance.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-instances-items-properties-name.md "undefined#/properties/compute_instance_templates/items/properties/instances/items/properties/name")

### name Type

`string`

## resource_name

                    Override for Terraform resource name. If unset, defaults to normalized name.
                    Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-instances-items-properties-resource_name.md "undefined#/properties/compute_instance_templates/items/properties/instances/items/properties/resource_name")

### resource_name Type

`string`
