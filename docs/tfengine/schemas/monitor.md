# Monitor Recipe

<!-- These files are auto generated -->

## Properties
| Property 	| Description 						| Type 	   			   | Required			   		   | Default             | Pattern 			 			 |
| --------- | ----------------------- | ---------------- | --------------------- | ------------------- | ------------------- |
| cloud_sql_region | Location of cloud sql instances. | string | false | - | - |
| compute_region | Location of compute instances. | string | false | - | - |
| forseti | Config for the Forseti instance. | object | false | - | - |
| forseti.domain | Domain for the Forseti instance. | string | false | - | - |
| forseti.network | Name of the Forseti network. | string | false | - | - |
| forseti.security_command_center_source_id | Security Command Center (SCC) Source ID used for Forseti notification.            To enable viewing Forseti violations in SCC:<br><br>1) Omit this field initially, generate the Terraform configs and do a                full deployment of Forseti;<br><br>2) Follow              [the guide](https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification)                to enable Forseti in SCC (you need a valid Forseti instance to do so)                and obtain the SCC source ID;<br><br>3) Add the ID through this field, generate the Terraform configs and                deploy Forseti again. | string | false | - | - |
| forseti.subnet | Name of the Forseti subnet. | string | false | - | - |
| project | Config of project to host monitoring resources | object | false | - | - |
| storage_location | Location of storage buckets. | string | false | - | - |
