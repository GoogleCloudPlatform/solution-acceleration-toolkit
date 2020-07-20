# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/gke_clusters/items/properties/master_authorized_networks/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-gke_clusters-items-properties-master_authorized_networks-items.md))

# undefined Properties

| Property                      | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                                             |
| :---------------------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [cidr_block](#cidr_block)     | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_authorized_networks-items-properties-cidr_block.md "undefined#/properties/gke_clusters/items/properties/master_authorized_networks/items/properties/cidr_block")     |
| [display_name](#display_name) | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_authorized_networks-items-properties-display_name.md "undefined#/properties/gke_clusters/items/properties/master_authorized_networks/items/properties/display_name") |

## cidr_block

CIDR block of the master authorized network.


`cidr_block`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_authorized_networks-items-properties-cidr_block.md "undefined#/properties/gke_clusters/items/properties/master_authorized_networks/items/properties/cidr_block")

### cidr_block Type

`string`

## display_name

Display name of the master authorized network.


`display_name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters-items-properties-master_authorized_networks-items-properties-display_name.md "undefined#/properties/gke_clusters/items/properties/master_authorized_networks/items/properties/display_name")

### display_name Type

`string`
