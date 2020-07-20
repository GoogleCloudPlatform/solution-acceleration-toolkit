# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/cloud_sql_instances/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-cloud_sql_instances-items.md))

# undefined Properties

| Property                                  | Type     | Required | Nullable       | Defined by                                                                                                                                                                                               |
| :---------------------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [cloud_sql_region](#cloud_sql_region)     | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-cloud_sql_region.md "undefined#/properties/cloud_sql_instances/items/properties/cloud_sql_region")     |
| [cloud_sql_zone](#cloud_sql_zone)         | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-cloud_sql_zone.md "undefined#/properties/cloud_sql_instances/items/properties/cloud_sql_zone")         |
| [name](#name)                             | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-name.md "undefined#/properties/cloud_sql_instances/items/properties/name")                             |
| [network](#network)                       | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-network.md "undefined#/properties/cloud_sql_instances/items/properties/network")                       |
| [network_project_id](#network_project_id) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-network_project_id.md "undefined#/properties/cloud_sql_instances/items/properties/network_project_id") |
| [resource_name](#resource_name)           | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-resource_name.md "undefined#/properties/cloud_sql_instances/items/properties/resource_name")           |
| [type](#type)                             | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-type.md "undefined#/properties/cloud_sql_instances/items/properties/type")                             |
| [user_name](#user_name)                   | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-user_name.md "undefined#/properties/cloud_sql_instances/items/properties/user_name")                   |
| [user_password](#user_password)           | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-user_password.md "undefined#/properties/cloud_sql_instances/items/properties/user_password")           |

## cloud_sql_region

Region to create cloud sql instance in. Can be defined in global data block.


`cloud_sql_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-cloud_sql_region.md "undefined#/properties/cloud_sql_instances/items/properties/cloud_sql_region")

### cloud_sql_region Type

`string`

## cloud_sql_zone

Zone to reate cloud sql instance in. Can be defined in global data block.


`cloud_sql_zone`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-cloud_sql_zone.md "undefined#/properties/cloud_sql_instances/items/properties/cloud_sql_zone")

### cloud_sql_zone Type

`string`

## name

Name of the cloud sql instance.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-name.md "undefined#/properties/cloud_sql_instances/items/properties/name")

### name Type

`string`

## network

Name of the network.


`network`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-network.md "undefined#/properties/cloud_sql_instances/items/properties/network")

### network Type

`string`

## network_project_id

Name of network project. If unset, will use the current project.


`network_project_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-network_project_id.md "undefined#/properties/cloud_sql_instances/items/properties/network_project_id")

### network_project_id Type

`string`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-resource_name.md "undefined#/properties/cloud_sql_instances/items/properties/resource_name")

### resource_name Type

`string`

## type

Type of the cloud sql instance. Currently only supports 'mysql'.


`type`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-type.md "undefined#/properties/cloud_sql_instances/items/properties/type")

### type Type

`string`

### type Constraints

**pattern**: the string must match the following regular expression: 

```regexp
^mysql$
```

[try pattern](https://regexr.com/?expression=%5Emysql%24 "try regular expression with regexr.com")

## user_name

Default user name.


`user_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-user_name.md "undefined#/properties/cloud_sql_instances/items/properties/user_name")

### user_name Type

`string`

## user_password

Default user password.


`user_password`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances-items-properties-user_password.md "undefined#/properties/cloud_sql_instances/items/properties/user_password")

### user_password Type

`string`
