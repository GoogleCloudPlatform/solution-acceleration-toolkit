# Org Monitor Recipe Schema

```txt
undefined
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                        |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [monitor.schema.json](monitor.schema.json "open original schema") |

## Org Monitor Recipe Type

unknown ([Org Monitor Recipe](monitor.md))

# Org Monitor Recipe Properties

| Property                              | Type     | Required | Nullable       | Defined by                                                                                            |
| :------------------------------------ | -------- | -------- | -------------- | :---------------------------------------------------------------------------------------------------- |
| [cloud_sql_region](#cloud_sql_region) | `string` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-cloud_sql_region.md "undefined#/properties/cloud_sql_region") |
| [compute_region](#compute_region)     | `string` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-compute_region.md "undefined#/properties/compute_region")     |
| [forseti](#forseti)                   | `object` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-forseti.md "undefined#/properties/forseti")                   |
| [project](#project)                   | `object` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-project.md "undefined#/properties/project")                   |
| [storage_location](#storage_location) | `string` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-storage_location.md "undefined#/properties/storage_location") |

## cloud_sql_region

Location of cloud sql instances.


`cloud_sql_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-cloud_sql_region.md "undefined#/properties/cloud_sql_region")

### cloud_sql_region Type

`string`

## compute_region

Location of compute instances.


`compute_region`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-compute_region.md "undefined#/properties/compute_region")

### compute_region Type

`string`

## forseti

Config for the Forseti instance.


`forseti`

-   is optional
-   Type: `object` ([Details](monitor-properties-forseti.md))
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-forseti.md "undefined#/properties/forseti")

### forseti Type

`object` ([Details](monitor-properties-forseti.md))

## project

Config of project to host monitoring resources


`project`

-   is optional
-   Type: `object` ([Details](monitor-properties-project.md))
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-project.md "undefined#/properties/project")

### project Type

`object` ([Details](monitor-properties-project.md))

## storage_location

Location of storage buckets.


`storage_location`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-storage_location.md "undefined#/properties/storage_location")

### storage_location Type

`string`
