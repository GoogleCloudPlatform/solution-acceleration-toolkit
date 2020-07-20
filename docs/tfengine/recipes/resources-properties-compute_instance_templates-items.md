# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/compute_instance_templates/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-compute_instance_templates-items.md))

# undefined Properties

| Property                                  | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                             |
| :---------------------------------------- | --------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [disk_size_gb](#disk_size_gb)             | `integer` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-disk_size_gb.md "undefined#/properties/compute_instance_templates/items/properties/disk_size_gb")             |
| [disk_type](#disk_type)                   | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-disk_type.md "undefined#/properties/compute_instance_templates/items/properties/disk_type")                   |
| [enable_shielded_vm](#enable_shielded_vm) | `boolean` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-enable_shielded_vm.md "undefined#/properties/compute_instance_templates/items/properties/enable_shielded_vm") |
| [image_family](#image_family)             | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-image_family.md "undefined#/properties/compute_instance_templates/items/properties/image_family")             |
| [image_project](#image_project)           | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-image_project.md "undefined#/properties/compute_instance_templates/items/properties/image_project")           |
| [instances](#instances)                   | `array`   | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-instances.md "undefined#/properties/compute_instance_templates/items/properties/instances")                   |
| [name_prefix](#name_prefix)               | `string`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-name_prefix.md "undefined#/properties/compute_instance_templates/items/properties/name_prefix")               |
| [network_project_id](#network_project_id) | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-network_project_id.md "undefined#/properties/compute_instance_templates/items/properties/network_project_id") |
| [preemptible](#preemptible)               | `boolean` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-preemptible.md "undefined#/properties/compute_instance_templates/items/properties/preemptible")               |
| [resource_name](#resource_name)           | `string`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-resource_name.md "undefined#/properties/compute_instance_templates/items/properties/resource_name")           |
| [service_account](#service_account)       | `string`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-service_account.md "undefined#/properties/compute_instance_templates/items/properties/service_account")       |
| [subnet](#subnet)                         | `string`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-subnet.md "undefined#/properties/compute_instance_templates/items/properties/subnet")                         |

## disk_size_gb

Disk space to set for the instance template.


`disk_size_gb`

-   is optional
-   Type: `integer`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-disk_size_gb.md "undefined#/properties/compute_instance_templates/items/properties/disk_size_gb")

### disk_size_gb Type

`integer`

## disk_type

Type of disk to use for the instance template.


`disk_type`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-disk_type.md "undefined#/properties/compute_instance_templates/items/properties/disk_type")

### disk_type Type

`string`

## enable_shielded_vm

Whether to enable shielded VM. Defaults to true.


`enable_shielded_vm`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-enable_shielded_vm.md "undefined#/properties/compute_instance_templates/items/properties/enable_shielded_vm")

### enable_shielded_vm Type

`boolean`

## image_family

Family of compute image to use.


`image_family`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-image_family.md "undefined#/properties/compute_instance_templates/items/properties/image_family")

### image_family Type

`string`

## image_project

Project of compute image to use.


`image_project`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-image_project.md "undefined#/properties/compute_instance_templates/items/properties/image_project")

### image_project Type

`string`

## instances

<https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/compute_instance>


`instances`

-   is optional
-   Type: `object[]` ([Details](resources-properties-compute_instance_templates-items-properties-instances-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-instances.md "undefined#/properties/compute_instance_templates/items/properties/instances")

### instances Type

`object[]` ([Details](resources-properties-compute_instance_templates-items-properties-instances-items.md))

## name_prefix

Name prefix of the instance template.


`name_prefix`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-name_prefix.md "undefined#/properties/compute_instance_templates/items/properties/name_prefix")

### name_prefix Type

`string`

## network_project_id

Name of network project. If unset, will use the current project.


`network_project_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-network_project_id.md "undefined#/properties/compute_instance_templates/items/properties/network_project_id")

### network_project_id Type

`string`

## preemptible

Whether the instance template can be preempted. Defaults to false.


`preemptible`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-preemptible.md "undefined#/properties/compute_instance_templates/items/properties/preemptible")

### preemptible Type

`boolean`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name_prefix.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-resource_name.md "undefined#/properties/compute_instance_templates/items/properties/resource_name")

### resource_name Type

`string`

## service_account

Email of service account to attach to this instance template.


`service_account`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-service_account.md "undefined#/properties/compute_instance_templates/items/properties/service_account")

### service_account Type

`string`

## subnet

Name of the the instance template's subnet.


`subnet`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates-items-properties-subnet.md "undefined#/properties/compute_instance_templates/items/properties/subnet")

### subnet Type

`string`
