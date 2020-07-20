# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/bastion_hosts/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-bastion_hosts-items.md))

# undefined Properties

| Property                                  | Type     | Required | Nullable       | Defined by                                                                                                                                                                                   |
| :---------------------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [compute_region](#compute_region)         | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-compute_region.md "undefined#/properties/bastion_hosts/items/properties/compute_region")         |
| [compute_zone](#compute_zone)             | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-compute_zone.md "undefined#/properties/bastion_hosts/items/properties/compute_zone")             |
| [image_family](#image_family)             | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-image_family.md "undefined#/properties/bastion_hosts/items/properties/image_family")             |
| [image_project](#image_project)           | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-image_project.md "undefined#/properties/bastion_hosts/items/properties/image_project")           |
| [members](#members)                       | `array`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-members.md "undefined#/properties/bastion_hosts/items/properties/members")                       |
| [name](#name)                             | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-name.md "undefined#/properties/bastion_hosts/items/properties/name")                             |
| [network](#network)                       | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-network.md "undefined#/properties/bastion_hosts/items/properties/network")                       |
| [network_project_id](#network_project_id) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-network_project_id.md "undefined#/properties/bastion_hosts/items/properties/network_project_id") |
| [scopes](#scopes)                         | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-scopes.md "undefined#/properties/bastion_hosts/items/properties/scopes")                         |
| [startup_script](#startup_script)         | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-startup_script.md "undefined#/properties/bastion_hosts/items/properties/startup_script")         |
| [subnet](#subnet)                         | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-subnet.md "undefined#/properties/bastion_hosts/items/properties/subnet")                         |

## compute_region

Region to create bastion host in. Can be defined in global data block.


`compute_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-compute_region.md "undefined#/properties/bastion_hosts/items/properties/compute_region")

### compute_region Type

`string`

## compute_zone

Zone to create bastion host in. Can be defined in global data block.


`compute_zone`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-compute_zone.md "undefined#/properties/bastion_hosts/items/properties/compute_zone")

### compute_zone Type

`string`

## image_family

Family of compute image to use.


`image_family`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-image_family.md "undefined#/properties/bastion_hosts/items/properties/image_family")

### image_family Type

`string`

## image_project

Project of compute image to use.


`image_project`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-image_project.md "undefined#/properties/bastion_hosts/items/properties/image_project")

### image_project Type

`string`

## members

Members who can access the bastion host.


`members`

-   is required
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-members.md "undefined#/properties/bastion_hosts/items/properties/members")

### members Type

`string[]`

## name

Name of bastion host.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-name.md "undefined#/properties/bastion_hosts/items/properties/name")

### name Type

`string`

## network

Name of the bastion host's network.


`network`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-network.md "undefined#/properties/bastion_hosts/items/properties/network")

### network Type

`string`

## network_project_id

Name of network project. If unset, will use the current project.


`network_project_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-network_project_id.md "undefined#/properties/bastion_hosts/items/properties/network_project_id")

### network_project_id Type

`string`

## scopes

Scopes to grant. If unset, will grant access to all cloud platform scopes.


`scopes`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-scopes.md "undefined#/properties/bastion_hosts/items/properties/scopes")

### scopes Type

`string[]`

## startup_script

Script to run on startup. Can be multi-line.


`startup_script`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-startup_script.md "undefined#/properties/bastion_hosts/items/properties/startup_script")

### startup_script Type

`string`

## subnet

Name of the bastion host's subnet.


`subnet`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts-items-properties-subnet.md "undefined#/properties/bastion_hosts/items/properties/subnet")

### subnet Type

`string`
