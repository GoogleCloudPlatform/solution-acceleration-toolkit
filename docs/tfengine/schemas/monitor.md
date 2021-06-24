# Monitor Recipe

<!-- These files are auto generated -->

## Properties
| Property 	| Description 						| Type 	   			   | Required			   		   | Default             | Pattern 			 			 |
| --------- | ----------------------- | ---------------- | --------------------- | ------------------- | ------------------- |
| cloud_sql_region | Location of cloud sql instances.<br><br> | string | false | - | - |
| compute_region | Location of compute instances.<br><br> | string | false | - | - |
| forseti | Config for the Forseti instance.<br><br> | object | false | - | - |
| forseti.domain | Domain for the Forseti instance.<br><br> | string | false | - | - |
| forseti.network | Name of the Forseti network.<br><br> | string | false | - | - |
| forseti.security_command_center_source_id | Security Command Center (SCC) Source ID used for Forseti notification.            To enable viewing Forseti violations in SCC:<br><br>1) Omit this field initially, generate the Terraform configs and do a                full deployment of Forseti;<br><br>2) Follow              [the guide](https://forsetisecurity.org/docs/v2.23/configure/notifier/#cloud-scc-notification)                to enable Forseti in SCC (you need a valid Forseti instance to do so)                and obtain the SCC source ID;<br><br>3) Add the ID through this field, generate the Terraform configs and                deploy Forseti again.<br><br> | string | false | - | - |
| forseti.subnet | Name of the Forseti subnet.<br><br> | string | false | - | - |
| project | Config of project to host monitoring resources<br><br> | object | false | - | - |
| storage_location | Location of storage buckets.<br><br> | string | false | - | - |
