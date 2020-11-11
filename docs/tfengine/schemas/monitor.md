# Monitor Recipe

<!-- These files are auto generated -->

## Properties

### cloud_sql_region

Location of cloud sql instances.

Type: string

### compute_region

Location of compute instances.

Type: string

### forseti

Config for the Forseti instance.

Type: object

### forseti.domain

Domain for the Forseti instance.

Type: string

### forseti.network

Name of the bastion host's network.

Type: string

### forseti.security_command_center_source_id

Security Command Center (SCC) Source ID used for Forseti notification.
To enable viewing Forseti violations in SCC:

1) Omit this field initially, generate the Terraform configs and do a
full deployment of Forseti;

2) Follow
[the guide](https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification)
to enable Forseti in SCC (you need a valid Forseti instance to do so)
and obtain the SCC source ID;

3) Add the ID through this field, generate the Terraform configs and
deploy Forseti again.

Type: string

### forseti.subnet

Name of the bastion host's subnet.

Type: string

### project

Config of project to host monitoring resources

Type: object

### storage_location

Location of storage buckets.

Type: string
