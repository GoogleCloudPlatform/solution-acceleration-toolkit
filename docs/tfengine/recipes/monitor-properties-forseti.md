# Untitled object in Org Monitor Recipe Schema

```txt
undefined#/properties/forseti
```

Config for the Forseti instance.


| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                                                      |
| :------------------ | ---------- | -------------- | ------------ | :---------------- | --------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Forbidden             | none                | [monitor.schema.json\*](../../../../../../../../../../tmp/182028425/monitor.schema.json "open original schema") |

## forseti Type

`object` ([Details](monitor-properties-forseti.md))

# undefined Properties

| Property                                                                | Type     | Required | Nullable       | Defined by                                                                                                                                                                    |
| :---------------------------------------------------------------------- | -------- | -------- | -------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [domain](#domain)                                                       | `string` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-forseti-properties-domain.md "undefined#/properties/forseti/properties/domain")                                                       |
| [security_command_center_source_id](#security_command_center_source_id) | `string` | Optional | cannot be null | [Org Monitor Recipe](monitor-properties-forseti-properties-security_command_center_source_id.md "undefined#/properties/forseti/properties/security_command_center_source_id") |

## domain

Domain for the Forseti instance.


`domain`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-forseti-properties-domain.md "undefined#/properties/forseti/properties/domain")

### domain Type

`string`

## security_command_center_source_id

            Security Command Center (SCC) Source ID used for Forseti notification.
            To enable viewing Forseti violations in SCC:
              1) Omit this field initially, generate the Terraform configs and do a
                full deployment of Forseti;
              2) Follow https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification
                to enable Forseti in SCC (you need a valid Forseti instance to do so)
                and obtain the SCC source ID;
              3) Add the ID through this field, generate the Terraform configs and
                deploy Forseti again.


`security_command_center_source_id`

-   is optional
-   Type: `string`
-   cannot be null
-   defined in: [Org Monitor Recipe](monitor-properties-forseti-properties-security_command_center_source_id.md "undefined#/properties/forseti/properties/security_command_center_source_id")

### security_command_center_source_id Type

`string`
