# Untitled undefined type in Recipe for resources within projects. Schema

```txt
undefined#/properties/pubsub_topics/items
```




| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                              |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | ----------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [resources.schema.json\*](resources.schema.json "open original schema") |

## items Type

unknown

# undefined Properties

| Property                                  | Type     | Required | Nullable       | Defined by                                                                                                                                                                                   |
| :---------------------------------------- | -------- | -------- | -------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)                             | `string` | Required | cannot be null | [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-name.md "undefined#/properties/pubsub_topics/items/properties/name")                             |
| [pull_subscriptions](#pull_subscriptions) | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-pull_subscriptions.md "undefined#/properties/pubsub_topics/items/properties/pull_subscriptions") |
| [push_subscriptions](#push_subscriptions) | `array`  | Optional | cannot be null | [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-push_subscriptions.md "undefined#/properties/pubsub_topics/items/properties/push_subscriptions") |

## name

Name of the topic.


`name`

-   is required
-   Type: `string`
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-name.md "undefined#/properties/pubsub_topics/items/properties/name")

### name Type

`string`

## pull_subscriptions

Pull subscriptions on the topic.


`pull_subscriptions`

-   is optional
-   Type: `object[]` ([Details](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-pull_subscriptions.md "undefined#/properties/pubsub_topics/items/properties/pull_subscriptions")

### pull_subscriptions Type

`object[]` ([Details](resources-properties-pubsub_topics-items-properties-pull_subscriptions-items.md))

## push_subscriptions

Push subscriptions on the topic.


`push_subscriptions`

-   is optional
-   Type: `object[]` ([Details](resources-properties-pubsub_topics-items-properties-push_subscriptions-items.md))
-   cannot be null
-   defined in: [Recipe for resources within projects.](resources-properties-pubsub_topics-items-properties-push_subscriptions.md "undefined#/properties/pubsub_topics/items/properties/push_subscriptions")

### push_subscriptions Type

`object[]` ([Details](resources-properties-pubsub_topics-items-properties-push_subscriptions-items.md))
