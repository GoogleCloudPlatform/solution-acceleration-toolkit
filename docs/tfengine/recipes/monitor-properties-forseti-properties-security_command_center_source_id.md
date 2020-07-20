# Untitled string in Org Monitor Recipe Schema

```txt
undefined#/properties/forseti/properties/security_command_center_source_id
```

            Security Command Center (SCC) Source ID used for Forseti notification.
            To enable viewing Forseti violations in SCC:
              1) Omit this field initially, generate the Terraform configs and do a
                full deployment of Forseti;
              2) Follow https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification
                to enable Forseti in SCC (you need a valid Forseti instance to do so)
                and obtain the SCC source ID;
              3) Add the ID through this field, generate the Terraform configs and
                deploy Forseti again.


| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                          |
| :------------------ | ---------- | -------------- | ----------------------- | :---------------- | --------------------- | ------------------- | ------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [monitor.schema.json\*](monitor.schema.json "open original schema") |

## security_command_center_source_id Type

`string`
