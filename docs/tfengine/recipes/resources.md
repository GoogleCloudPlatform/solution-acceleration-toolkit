# Recipe for resources within projects. Schema

```txt
undefined
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                            |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json](resources.schema.json "open original schema") |

## Recipe for resources within projects. Type

unknown ([Recipe for resources within projects.](resources.md))

# Recipe for resources within projects. Properties

| Property                                                  | Type     | Required | Nullable       | Defined by                                                                                                                                     |
| :-------------------------------------------------------- | -------- | -------- | -------------- | :--------------------------------------------------------------------------------------------------------------------------------------------- |
| [bastion_hosts](#bastion_hosts)                           | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bastion_hosts.md "undefined#/properties/bastion_hosts")                           |
| [bigquery_datasets](#bigquery_datasets)                   | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets.md "undefined#/properties/bigquery_datasets")                   |
| [binary_authorization](#binary_authorization)             | `object` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-binary_authorization.md "undefined#/properties/binary_authorization")             |
| [cloud_sql_instances](#cloud_sql_instances)               | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-cloud_sql_instances.md "undefined#/properties/cloud_sql_instances")               |
| [compute_instance_templates](#compute_instance_templates) | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_instance_templates.md "undefined#/properties/compute_instance_templates") |
| [compute_networks](#compute_networks)                     | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_networks.md "undefined#/properties/compute_networks")                     |
| [compute_routers](#compute_routers)                       | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-compute_routers.md "undefined#/properties/compute_routers")                       |
| [dns_zones](#dns_zones)                                   | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-dns_zones.md "undefined#/properties/dns_zones")                                   |
| [gke_clusters](#gke_clusters)                             | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-gke_clusters.md "undefined#/properties/gke_clusters")                             |
| [healthcare_datasets](#healthcare_datasets)               | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-healthcare_datasets.md "undefined#/properties/healthcare_datasets")               |
| [iam_members](#iam_members)                               | `object` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-iam_members.md "undefined#/properties/iam_members")                               |
| [pubsub_topics](#pubsub_topics)                           | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-pubsub_topics.md "undefined#/properties/pubsub_topics")                           |
| [secrets](#secrets)                                       | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-secrets.md "undefined#/properties/secrets")                                       |
| [service_accounts](#service_accounts)                     | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-service_accounts.md "undefined#/properties/service_accounts")                     |
| [storage_buckets](#storage_buckets)                       | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-storage_buckets.md "undefined#/properties/storage_buckets")                       |
| [terraform_addons](#terraform_addons)                     | `object` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-terraform_addons.md "undefined#/properties/terraform_addons")                     |

## bastion_hosts

<https://github.com/terraform-google-modules/terraform-google-bastion-host>


`bastion_hosts`

-   is optional
-   Type: `object[]` ([Details](resources-properties-bastion_hosts-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bastion_hosts.md "undefined#/properties/bastion_hosts")

### bastion_hosts Type

`object[]` ([Details](resources-properties-bastion_hosts-items.md))

## bigquery_datasets

<https://github.com/terraform-google-modules/terraform-google-bigquery>


`bigquery_datasets`

-   is optional
-   Type: `object[]` ([Details](resources-properties-bigquery_datasets-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets.md "undefined#/properties/bigquery_datasets")

### bigquery_datasets Type

`object[]` ([Details](resources-properties-bigquery_datasets-items.md))

## binary_authorization

A policy for container image binary authorization.


`binary_authorization`

-   is optional
-   Type: `object` ([Details](resources-properties-binary_authorization.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-binary_authorization.md "undefined#/properties/binary_authorization")

### binary_authorization Type

`object` ([Details](resources-properties-binary_authorization.md))

## cloud_sql_instances

<https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql>


`cloud_sql_instances`

-   is optional
-   Type: `object[]` ([Details](resources-properties-cloud_sql_instances-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-cloud_sql_instances.md "undefined#/properties/cloud_sql_instances")

### cloud_sql_instances Type

`object[]` ([Details](resources-properties-cloud_sql_instances-items.md))

## compute_instance_templates

<https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template>


`compute_instance_templates`

-   is optional
-   Type: `object[]` ([Details](resources-properties-compute_instance_templates-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_instance_templates.md "undefined#/properties/compute_instance_templates")

### compute_instance_templates Type

`object[]` ([Details](resources-properties-compute_instance_templates-items.md))

## compute_networks

<https://github.com/terraform-google-modules/terraform-google-network>


`compute_networks`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_networks.md "undefined#/properties/compute_networks")

### compute_networks Type

unknown\[]

## compute_routers

<https://github.com/terraform-google-modules/terraform-google-cloud-router>


`compute_routers`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-compute_routers.md "undefined#/properties/compute_routers")

### compute_routers Type

unknown\[]

## dns_zones

<https://github.com/terraform-google-modules/terraform-google-cloud-dns>


`dns_zones`

-   is optional
-   Type: `object[]` ([Details](resources-properties-dns_zones-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-dns_zones.md "undefined#/properties/dns_zones")

### dns_zones Type

`object[]` ([Details](resources-properties-dns_zones-items.md))

## gke_clusters

<https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant>


`gke_clusters`

-   is optional
-   Type: `object[]` ([Details](resources-properties-gke_clusters-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-gke_clusters.md "undefined#/properties/gke_clusters")

### gke_clusters Type

`object[]` ([Details](resources-properties-gke_clusters-items.md))

## healthcare_datasets

<https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql>


`healthcare_datasets`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-healthcare_datasets.md "undefined#/properties/healthcare_datasets")

### healthcare_datasets Type

unknown\[]

## iam_members

Map of IAM role to list of members to grant access to the role.


`iam_members`

-   is optional
-   Type: `object` ([Details](resources-properties-iam_members.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-iam_members.md "undefined#/properties/iam_members")

### iam_members Type

`object` ([Details](resources-properties-iam_members.md))

## pubsub_topics

<https://github.com/terraform-google-modules/terraform-google-pubsub>


`pubsub_topics`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-pubsub_topics.md "undefined#/properties/pubsub_topics")

### pubsub_topics Type

unknown\[]

## secrets

<https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html>


`secrets`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-secrets.md "undefined#/properties/secrets")

### secrets Type

unknown\[]

## service_accounts

<https://www.terraform.io/docs/providers/google/r/google_service_account.html>


`service_accounts`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-service_accounts.md "undefined#/properties/service_accounts")

### service_accounts Type

unknown\[]

## storage_buckets

<https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql>


`storage_buckets`

-   is optional
-   Type: unknown\[]
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-storage_buckets.md "undefined#/properties/storage_buckets")

### storage_buckets Type

unknown\[]

## terraform_addons

        Additional Terraform configuration for the project deployment.
        Can be used to support arbitrary resources not supported in the following list.
        For schema see ./deployment.hcl.


`terraform_addons`

-   is optional
-   Type: `object` ([Details](resources-properties-terraform_addons.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-terraform_addons.md "undefined#/properties/terraform_addons")

### terraform_addons Type

`object` ([Details](resources-properties-terraform_addons.md))
