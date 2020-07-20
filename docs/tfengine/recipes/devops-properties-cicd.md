# Untitled object in Devops Recipe Schema

```txt
undefined#/properties/cicd
```

Config for CICD. If unset there will be no CICD.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                        |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [devops.schema.json\*](devops.schema.json "open original schema") |

## cicd Type

`object` ([Details](devops-properties-cicd.md))

# undefined Properties

| Property                                            | Type     | Required | Nullable       | Defined by                                                                                                                                    |
| :-------------------------------------------------- | -------- | -------- | -------------- | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| [apply_trigger](#apply_trigger)                     | `object` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-apply_trigger.md "undefined#/properties/cicd/properties/apply_trigger")                     |
| [branch_regex](#branch_regex)                       | `string` | Required | cannot be null | [Devops Recipe](devops-properties-cicd-properties-branch_regex.md "undefined#/properties/cicd/properties/branch_regex")                       |
| [build_viewers](#build_viewers)                     | `array`  | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-build_viewers.md "undefined#/properties/cicd/properties/build_viewers")                     |
| [cloud_source_repository](#cloud_source_repository) | `object` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-cloud_source_repository.md "undefined#/properties/cicd/properties/cloud_source_repository") |
| [github](#github)                                   | `object` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-github.md "undefined#/properties/cicd/properties/github")                                   |
| [managed_services](#managed_services)               | `array`  | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-managed_services.md "undefined#/properties/cicd/properties/managed_services")               |
| [plan_trigger](#plan_trigger)                       | `object` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-plan_trigger.md "undefined#/properties/cicd/properties/plan_trigger")                       |
| [terraform_root](#terraform_root)                   | `string` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-terraform_root.md "undefined#/properties/cicd/properties/terraform_root")                   |
| [validate_trigger](#validate_trigger)               | `object` | Optional | cannot be null | [Devops Recipe](devops-properties-cicd-properties-validate_trigger.md "undefined#/properties/cicd/properties/validate_trigger")               |

## apply_trigger

            Config block for the postsubmit apply/deployyemt Cloud Build trigger. If specified,
            create the trigger and grant the Cloud Build Service Account necessary permissions
            to perform the build.


`apply_trigger`

-   is optional
-   Type: `object` ([Details](devops-properties-cicd-properties-apply_trigger.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-apply_trigger.md "undefined#/properties/cicd/properties/apply_trigger")

### apply_trigger Type

`object` ([Details](devops-properties-cicd-properties-apply_trigger.md))

## branch_regex

Regex of the branches to set the Cloud Build Triggers to monitor.


`branch_regex`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-branch_regex.md "undefined#/properties/cicd/properties/branch_regex")

### branch_regex Type

`string`

## build_viewers

IAM members to grant `cloudbuild.builds.viewer` role in the devops project to see CICD results.


`build_viewers`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-build_viewers.md "undefined#/properties/cicd/properties/build_viewers")

### build_viewers Type

`string[]`

## cloud_source_repository

Config for Google Cloud Source Repository Cloud Build triggers.


`cloud_source_repository`

-   is optional
-   Type: `object` ([Details](devops-properties-cicd-properties-cloud_source_repository.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-cloud_source_repository.md "undefined#/properties/cicd/properties/cloud_source_repository")

### cloud_source_repository Type

`object` ([Details](devops-properties-cicd-properties-cloud_source_repository.md))

## github

Config for GitHub Cloud Build triggers.


`github`

-   is optional
-   Type: `object` ([Details](devops-properties-cicd-properties-github.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-github.md "undefined#/properties/cicd/properties/github")

### github Type

`object` ([Details](devops-properties-cicd-properties-github.md))

## managed_services

            APIs to enable in the devops project so the Cloud Build service account can manage
            those services in other projects.


`managed_services`

-   is optional
-   Type: `string[]`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-managed_services.md "undefined#/properties/cicd/properties/managed_services")

### managed_services Type

`string[]`

## plan_trigger

            Config block for the presubmit plan Cloud Build trigger. If specified, create
            the trigger and grant the Cloud Build Service Account necessary permissions to perform
            the build.


`plan_trigger`

-   is optional
-   Type: `object` ([Details](devops-properties-cicd-properties-plan_trigger.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-plan_trigger.md "undefined#/properties/cicd/properties/plan_trigger")

### plan_trigger Type

`object` ([Details](devops-properties-cicd-properties-plan_trigger.md))

## terraform_root

Path of the directory relative to the repo root containing the Terraform configs.


`terraform_root`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-terraform_root.md "undefined#/properties/cicd/properties/terraform_root")

### terraform_root Type

`string`

## validate_trigger

            Config block for the presubmit validation Cloud Build trigger. If specified, create
            the trigger and grant the Cloud Build Service Account necessary permissions to perform
            the build.


`validate_trigger`

-   is optional
-   Type: `object` ([Details](devops-properties-cicd-properties-validate_trigger.md))
-   cannot be null
-   defined in: [Devops Recipe](devops-properties-cicd-properties-validate_trigger.md "undefined#/properties/cicd/properties/validate_trigger")

### validate_trigger Type

`object` ([Details](devops-properties-cicd-properties-validate_trigger.md))
