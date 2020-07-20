# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/gke_clusters/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-gke_clusters-items.md))

# undefined Properties

| Property                                                  | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                 |
| :-------------------------------------------------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [gke_region](#gke_region)                                 | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-gke_region.md "undefined#/properties/gke_clusters/items/properties/gke_region")                                 |
| [ip_range_pods_name](#ip_range_pods_name)                 | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-ip_range_pods_name.md "undefined#/properties/gke_clusters/items/properties/ip_range_pods_name")                 |
| [ip_range_services_name](#ip_range_services_name)         | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-ip_range_services_name.md "undefined#/properties/gke_clusters/items/properties/ip_range_services_name")         |
| [master_authorized_networks](#master_authorized_networks) | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_authorized_networks.md "undefined#/properties/gke_clusters/items/properties/master_authorized_networks") |
| [master_ipv4_cidr_block](#master_ipv4_cidr_block)         | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_ipv4_cidr_block.md "undefined#/properties/gke_clusters/items/properties/master_ipv4_cidr_block")         |
| [name](#name)                                             | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-name.md "undefined#/properties/gke_clusters/items/properties/name")                                             |
| [network](#network)                                       | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-network.md "undefined#/properties/gke_clusters/items/properties/network")                                       |
| [network_project_id](#network_project_id)                 | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-network_project_id.md "undefined#/properties/gke_clusters/items/properties/network_project_id")                 |
| [resource_name](#resource_name)                           | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-resource_name.md "undefined#/properties/gke_clusters/items/properties/resource_name")                           |
| [subnet](#subnet)                                         | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-subnet.md "undefined#/properties/gke_clusters/items/properties/subnet")                                         |

## gke_region

Region to create GKE cluster in. Can be defined in global data block.


`gke_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-gke_region.md "undefined#/properties/gke_clusters/items/properties/gke_region")

### gke_region Type

`string`

## ip_range_pods_name

Name of the secondary subnet ip range to use for pods.


`ip_range_pods_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-ip_range_pods_name.md "undefined#/properties/gke_clusters/items/properties/ip_range_pods_name")

### ip_range_pods_name Type

`string`

## ip_range_services_name

Name of the secondary subnet range to use for services.


`ip_range_services_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-ip_range_services_name.md "undefined#/properties/gke_clusters/items/properties/ip_range_services_name")

### ip_range_services_name Type

`string`

## master_authorized_networks

              List of master authorized networks. If none are provided, disallow external
              access (except the cluster node IPs, which GKE automatically allows).


`master_authorized_networks`

-   is optional
-   Type: `object[]` ([Details](resources-properties-gke_clusters-items-properties-master_authorized_networks-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_authorized_networks.md "undefined#/properties/gke_clusters/items/properties/master_authorized_networks")

### master_authorized_networks Type

`object[]` ([Details](resources-properties-gke_clusters-items-properties-master_authorized_networks-items.md))

## master_ipv4_cidr_block

IP range in CIDR notation to use for the hosted master network.


`master_ipv4_cidr_block`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_ipv4_cidr_block.md "undefined#/properties/gke_clusters/items/properties/master_ipv4_cidr_block")

### master_ipv4_cidr_block Type

`string`

## name

Name of GKE cluster.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-name.md "undefined#/properties/gke_clusters/items/properties/name")

### name Type

`string`

## network

Name of the GKE cluster's network.


`network`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-network.md "undefined#/properties/gke_clusters/items/properties/network")

### network Type

`string`

## network_project_id

Name of network project. If unset, will use the current project.


`network_project_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-network_project_id.md "undefined#/properties/gke_clusters/items/properties/network_project_id")

### network_project_id Type

`string`

## resource_name

              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.


`resource_name`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-resource_name.md "undefined#/properties/gke_clusters/items/properties/resource_name")

### resource_name Type

`string`

## subnet

Name of the GKE cluster's subnet.


`subnet`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-subnet.md "undefined#/properties/gke_clusters/items/properties/subnet")

### subnet Type

`string`
