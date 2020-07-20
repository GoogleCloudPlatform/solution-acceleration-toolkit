# Untitled object in Recipe for resources within projects. Schema

```txt
undefined#/properties/pubsub_topics/items/properties/pull_subscriptions/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                          |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](../../../../../../../../../../tmp/182028425/resources.schema.json "open original schema") |

## items Type

`object` ([Details](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items.md))

# undefined Properties

| Property                                      | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                                                                               |
| :-------------------------------------------- | --------- | -------- | -------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ack_deadline_seconds](#ack_deadline_seconds) | `integer` | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items-properties-ack_deadline_seconds.md "undefined#/properties/pubsub_topics/items/properties/pull_subscriptions/items/properties/ack_deadline_seconds") |
| [name](#name)                                 | `string`  | Required | cannot be null | [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items-properties-name.md "undefined#/properties/pubsub_topics/items/properties/pull_subscriptions/items/properties/name")                                 |

## ack_deadline_seconds

Deadline to wait for acknowledgement.


`ack_deadline_seconds`

-   is optional
-   Type: `integer`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items-properties-ack_deadline_seconds.md "undefined#/properties/pubsub_topics/items/properties/pull_subscriptions/items/properties/ack_deadline_seconds")

### ack_deadline_seconds Type

`integer`

## name

Name of subscription.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items-properties-name.md "undefined#/properties/pubsub_topics/items/properties/pull_subscriptions/items/properties/name")

### name Type

`string`
