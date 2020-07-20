# Untitled object in Recipe for creating GCP projects. Schema

```txt
undefined#/properties/project
```

Config for the project.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [project.schema.json\*](project.schema.json "open original schema") |

## project Type

`object` ([Details](project-properties-project.md))

# undefined Properties

| Property                                        | Type          | Required | Nullable       | Defined by                                                                                                                                                           |
| :---------------------------------------------- | ------------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [apis](#apis)                                   | `array`       | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-apis.md "undefined#/properties/project/properties/apis")                                   |
| [is_shared_vpc_host](#is_shared_vpc_host)       | `boolean`     | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-is_shared_vpc_host.md "undefined#/properties/project/properties/is_shared_vpc_host")       |
| [project_id](#project_id)                       | `string`      | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-project_id.md "undefined#/properties/project/properties/project_id")                       |
| [shared_vpc_attachment](#shared_vpc_attachment) | `object`      | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment.md "undefined#/properties/project/properties/shared_vpc_attachment") |
| [terraform_addons](#terraform_addons)           | Not specified | Optional | cannot be null | [Recipe for creating GCP projects.](project-properties-project-properties-terraform_addons.md "undefined#/properties/project/properties/terraform_addons")           |

## apis

APIs to enable in the project.


`apis`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-apis.md "undefined#/properties/project/properties/apis")

### apis Type

`string[]`

## is_shared_vpc_host

Whether this project is a shared VPC host. Defaults to 'false'.


`is_shared_vpc_host`

-   is optional
-   Type: `boolean`
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-is_shared_vpc_host.md "undefined#/properties/project/properties/is_shared_vpc_host")

### is_shared_vpc_host Type

`boolean`

## project_id

ID of project to create.


`project_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-project_id.md "undefined#/properties/project/properties/project_id")

### project_id Type

`string`

## shared_vpc_attachment

If set, treats this project as a shared VPC service project.


`shared_vpc_attachment`

-   is optional
-   Type: `object` ([Details](project-properties-project-properties-shared_vpc_attachment.md))
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-shared_vpc_attachment.md "undefined#/properties/project/properties/shared_vpc_attachment")

### shared_vpc_attachment Type

`object` ([Details](project-properties-project-properties-shared_vpc_attachment.md))

## terraform_addons

            Additional Terraform configuration for the project deployment.
            For schema see ./deployment.hcl.


`terraform_addons`

-   is optional
-   Type: unknown
-   cannot be null
-   defined in: [Recipe for creating GCP projects.](project-properties-project-properties-terraform_addons.md "undefined#/properties/project/properties/terraform_addons")

### terraform_addons Type

unknown
