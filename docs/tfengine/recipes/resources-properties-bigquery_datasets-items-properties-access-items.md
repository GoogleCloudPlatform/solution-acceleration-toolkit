# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/bigquery_datasets/items/properties/access/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-bigquery_datasets-items-properties-access-items.md))

# undefined Properties

| Property                          | Type     | Required | Nullable       | Defined by                                                                                                                                                                                                                                   |
| :-------------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [group_by_email](#group_by_email) | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-group_by_email.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/group_by_email") |
| [role](#role)                     | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-role.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/role")                     |
| [special_group](#special_group)   | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-special_group.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/special_group")   |
| [user_by_email](#user_by_email)   | `string` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-user_by_email.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/user_by_email")   |

## group_by_email

An email address of a Google Group to grant access to.


`group_by_email`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-group_by_email.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/group_by_email")

### group_by_email Type

`string`

## role

Role to grant.


`role`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-role.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/role")

### role Type

`string`

## special_group

A special group to grant access to.


`special_group`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-special_group.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/special_group")

### special_group Type

`string`

## user_by_email

An email address of a user to grant access to.


`user_by_email`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-bigquery_datasets-items-properties-access-items-properties-user_by_email.md "undefined#/properties/bigquery_datasets/items/properties/access/items/properties/user_by_email")

### user_by_email Type

`string`
