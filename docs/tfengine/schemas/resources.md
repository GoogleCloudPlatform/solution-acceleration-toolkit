# Recipe for resources within projects

<!-- These files are auto generated -->

## Properties
| Property 	| Description 						| Type 	   			   | Required			   		   | Default             | Pattern 			 			 |
| --------- | ----------------------- | ---------------- | --------------------- | ------------------- | ------------------- |
| bastion_hosts | [Module](https://github.com/terraform-google-modules/terraform-google-bastion-host)<br><br> | array(object) | false | - | - |
| bastion_hosts.compute_region | Region to create bastion host in. Can be defined in global data block.<br><br> | string | false | - | - |
| bastion_hosts.compute_zone | Zone to create bastion host in. Can be defined in global data block.<br><br> | string | false | - | - |
| bastion_hosts.image_family | Family of compute image to use.<br><br> | string | false | - | - |
| bastion_hosts.image_project | Project of compute image to use.<br><br> | string | false | - | - |
| bastion_hosts.labels | Labels to set on the host.<br><br> | object | false | - | - |
| bastion_hosts.members | Members who can access the bastion host.<br><br> | array(string) | true | - | - |
| bastion_hosts.name | Name of bastion host.<br><br> | string | true | - | - |
| bastion_hosts.network | Name of the bastion host's network.<br><br> | string | true | - | - |
| bastion_hosts.network_project_id | Name of network project.              If unset, the current project will be used.<br><br> | string | false | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| bastion_hosts.scopes | Scopes to grant. If unset, will grant access to all cloud platform scopes.<br><br> | array(string) | false | - | - |
| bastion_hosts.startup_script | Script to run on startup. Can be multi-line.<br><br> | string | false | - | - |
| bastion_hosts.subnet | Name of the bastion host's subnet.<br><br> | string | true | - | - |
| bigquery_datasets | [Module](https://github.com/terraform-google-modules/terraform-google-bigquery)<br><br> | array(object) | false | - | - |
| bigquery_datasets.access | Access for this bigquery dataset.              Each object should contain exactly one of group_by_email, user_by_email, special_group.<br><br> | array(object) | false | - | - |
| bigquery_datasets.access.group_by_email | An email address of a Google Group to grant access to.<br><br> | string | false | - | - |
| bigquery_datasets.access.role | Role to grant.<br><br> | string | false | - | - |
| bigquery_datasets.access.special_group | A special group to grant access to.<br><br> | string | false | - | - |
| bigquery_datasets.access.user_by_email | An email address of a user to grant access to.<br><br> | string | false | - | - |
| bigquery_datasets.bigquery_location | Location to create the bigquery dataset. Can be defined in global data block.<br><br> | string | false | - | - |
| bigquery_datasets.dataset_id | ID of bigquery dataset.<br><br> | string | true | - | - |
| bigquery_datasets.default_table_expiration_ms | Expiration in milliseconds.<br><br> | integer | false | - | - |
| bigquery_datasets.labels | Labels to set on the dataset.<br><br> | object | false | - | - |
| bigquery_datasets.resource_name | Override for Terraform resource name.              If unset, defaults to normalized dataset_id.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| binary_authorization | A policy for container image binary authorization.<br><br> | object | false | - | - |
| binary_authorization.admission_whitelist_patterns | A whitelist of image patterns to exclude from admission rules.<br><br> | array(object) | false | - | - |
| binary_authorization.admission_whitelist_patterns.name_pattern | An image name pattern to whitelist, in the form registry/path/to/image.                  This supports a trailing * as a wildcard, but this is allowed                  only in text after the registry/ part."<br><br> | string | false | - | - |
| cloud_sql_instances | [Module](https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql)<br><br> | array(object) | false | - | - |
| cloud_sql_instances.cloud_sql_region | Region to create cloud sql instance in. Can be defined in global data block.<br><br> | string | false | - | - |
| cloud_sql_instances.cloud_sql_zone | Zone to reate cloud sql instance in. Can be defined in global data block.<br><br> | string | false | - | - |
| cloud_sql_instances.deletion_protection | Used to block Terraform from deleting a SQL Instance. Defaults to true.<br><br> | boolean | false | - | - |
| cloud_sql_instances.labels | Labels to set on the instance.<br><br> | object | false | - | - |
| cloud_sql_instances.name | Name of the cloud sql instance.<br><br> | string | true | - | - |
| cloud_sql_instances.network | Name of the network.<br><br> | string | false | - | - |
| cloud_sql_instances.network_project_id | Name of network project.              If unset, the current project will be used.<br><br> | string | false | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| cloud_sql_instances.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| cloud_sql_instances.tier | The              [tier](https://cloud.google.com/sql/docs/mysql/instance-settings#machine-type-2ndgen)              for the master instance.<br><br> | string | false | - | - |
| cloud_sql_instances.type | Type of the cloud sql instance. Currently only supports 'mysql'.<br><br> | string | false | - | ^mysql$ |
| cloud_sql_instances.user_name | Default user name.<br><br> | string | false | - | - |
| cloud_sql_instances.user_password | Default user password.<br><br> | string | false | - | - |
| compute_instance_templates | [Module](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)<br><br> | array(object) | false | - | - |
| compute_instance_templates.disk_size_gb | Disk space to set for the instance template.<br><br> | integer | false | - | - |
| compute_instance_templates.disk_type | Type of disk to use for the instance template.<br><br> | string | false | - | - |
| compute_instance_templates.enable_shielded_vm | Whether to enable shielded VM. Defaults to true.<br><br> | boolean | false | - | - |
| compute_instance_templates.image_family | Family of compute image to use.<br><br> | string | false | - | - |
| compute_instance_templates.image_project | Project of compute image to use.<br><br> | string | false | - | - |
| compute_instance_templates.instances | [Module](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/compute_instance)<br><br> | array(object) | false | - | - |
| compute_instance_templates.instances.access_configs | Access configurations, i.e. IPs via which this instance can                    be accessed via the Internet. Omit to ensure that the                    instance is not accessible from the Internet.<br><br> | array(object) | false | - | - |
| compute_instance_templates.instances.access_configs.nat_ip | The IP address that will be 1:1 mapped to the instance's network ip.<br><br> | string | true | - | - |
| compute_instance_templates.instances.access_configs.network_tier | The networking tier used for configuring this instance.<br><br> | string | false | - | - |
| compute_instance_templates.instances.name | Name of instance.<br><br> | string | true | - | - |
| compute_instance_templates.instances.resource_name | Override for Terraform resource name.                    If unset, defaults to normalized name.                    Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| compute_instance_templates.labels | Labels to set on the instance template.<br><br> | object | false | - | - |
| compute_instance_templates.metadata | Metadata to set on the instance template.<br><br> | object | false | - | - |
| compute_instance_templates.name_prefix | Name prefix of the instance template.<br><br> | string | true | - | - |
| compute_instance_templates.network_project_id | Name of network project.              If unset, the current project will be used.<br><br> | string | false | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| compute_instance_templates.preemptible | Whether the instance template can be preempted. Defaults to false.<br><br> | boolean | false | - | - |
| compute_instance_templates.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name_prefix.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| compute_instance_templates.service_account | Email of service account to attach to this instance template.<br><br> | string | true | - | - |
| compute_instance_templates.startup_script | Script to run on startup. Can be multi-line.<br><br> | string | false | - | - |
| compute_instance_templates.subnet | Name of the the instance template's subnet.<br><br> | string | true | - | - |
| compute_instance_templates.tags | [Network tags](https://cloud.google.com/vpc/docs/add-remove-network-tags)              for the instance template."<br><br> | array(string) | false | - | - |
| compute_networks | [Module](https://github.com/terraform-google-modules/terraform-google-network)<br><br> | array() | false | - | - |
| compute_networks.cloud_sql_private_service_access | Whether to enable Cloud SQL private service access. Defaults to false.<br><br> | object | false | - | - |
| compute_networks.name | Name of network.<br><br> | string | true | - | - |
| compute_networks.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| compute_networks.subnets | Subnetworks within the network.<br><br> | array(object) | false | - | - |
| compute_networks.subnets.compute_region | Region to create subnet in. Can be defined in global data block.<br><br> | string | false | - | - |
| compute_networks.subnets.ip_range | IP range of the subnet.<br><br> | string | false | - | - |
| compute_networks.subnets.name | Name of subnet.<br><br> | string | true | - | - |
| compute_networks.subnets.secondary_ranges | Secondary ranges of the subnet.<br><br> | array(object) | false | - | - |
| compute_networks.subnets.secondary_ranges.ip_range | IP range for the secondary range.<br><br> | string | false | - | - |
| compute_networks.subnets.secondary_ranges.name | Name of secondary range.<br><br> | string | true | - | - |
| compute_routers | [Module](https://github.com/terraform-google-modules/terraform-google-cloud-router)<br><br> | array() | false | - | - |
| compute_routers.compute_region | Region to create subnet in. Can be defined in global data block.<br><br> | string | false | - | - |
| compute_routers.name | Name of router.<br><br> | string | true | - | - |
| compute_routers.nats | NATs to attach to the router.<br><br> | array(object) | false | - | - |
| compute_routers.nats.name | Name of NAT.<br><br> | string | true | - | - |
| compute_routers.nats.source_subnetwork_ip_ranges_to_nat | How NAT should be configured per Subnetwork.<br><br> | string | false | - | - |
| compute_routers.nats.subnetworks | Subnet NAT configurations.                    Only applicable if 'source_subnetwork_ip_ranges_to_nat' is 'LIST_OF_SUBNETWORKS'.<br><br> | array(object) | false | - | - |
| compute_routers.nats.subnetworks.name | Name of subnet.<br><br> | string | true | - | - |
| compute_routers.nats.subnetworks.secondary_ip_range_names | List of the secondary ranges of the subnetwork that are allowed to use NAT.                          Only applicable if one of the values in 'source_ip_ranges_to_nat' is 'LIST_OF_SECONDARY_IP_RANGES'.<br><br> | array(string) | false | - | - |
| compute_routers.nats.subnetworks.source_ip_ranges_to_nat | List of options for which source IPs in the subnetwork should have NAT enabled.<br><br> | array(string) | true | - | - |
| compute_routers.network | Name of network the router belongs to.<br><br> | string | false | - | - |
| compute_routers.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| dns_zones | [Module](https://github.com/terraform-google-modules/terraform-google-cloud-dns)<br><br> | array(object) | false | - | - |
| dns_zones.domain | Domain of DNS zone. Must end with period.<br><br> | string | true | - | ^.+\.$ |
| dns_zones.name | Name of DNS zone.<br><br> | - | true | - | - |
| dns_zones.record_sets | Records managed by the DNS zone.<br><br> | array(object) | true | - | - |
| dns_zones.record_sets.name | Name of record set.<br><br> | string | false | - | - |
| dns_zones.record_sets.records | Data of the record set.<br><br> | array(string) | false | - | - |
| dns_zones.record_sets.ttl | Time to live of this record set, in seconds.<br><br> | integer | false | - | - |
| dns_zones.record_sets.type | Type of record set.<br><br> | string | false | - | - |
| dns_zones.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| dns_zones.type | Type of DNS zone.<br><br> | string | true | - | - |
| gke_clusters | [Module](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant)<br><br> | array(object) | false | - | - |
| gke_clusters.gke_region | Region to create GKE cluster in. Can be defined in global data block.<br><br> | string | false | - | - |
| gke_clusters.ip_range_pods_name | Name of the secondary subnet ip range to use for pods.<br><br> | string | false | - | - |
| gke_clusters.ip_range_services_name | Name of the secondary subnet range to use for services.<br><br> | string | false | - | - |
| gke_clusters.istio | Whether or not to enable Istio addon.<br><br> | boolean | false | - | - |
| gke_clusters.labels | Labels to set on the cluster.<br><br> | object | false | - | - |
| gke_clusters.master_authorized_networks | List of master authorized networks. If none are provided, disallow external              access (except the cluster node IPs, which GKE automatically allows).<br><br> | array(object) | false | - | - |
| gke_clusters.master_authorized_networks.cidr_block | CIDR block of the master authorized network.<br><br> | string | true | - | - |
| gke_clusters.master_authorized_networks.display_name | Display name of the master authorized network.<br><br> | string | true | - | - |
| gke_clusters.master_ipv4_cidr_block | IP range in CIDR notation to use for the hosted master network.<br><br> | string | false | - | - |
| gke_clusters.name | Name of GKE cluster.<br><br> | string | true | - | - |
| gke_clusters.network | Name of the GKE cluster's network.<br><br> | string | false | - | - |
| gke_clusters.network_project_id | Name of network project.              If unset, the current project will be used.<br><br> | string | false | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| gke_clusters.node_pools | List of maps containing node pools.              For supported fields, see the              [module example](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/examples/node_pool_update_variant).<br><br> | array(object) | false | - | - |
| gke_clusters.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| gke_clusters.service_account | Use the given service account for nodes rather than creating a              new dedicated service account.<br><br> | string | false | - | - |
| gke_clusters.subnet | Name of the GKE cluster's subnet.<br><br> | string | false | - | - |
| groups | [Module](https://github.com/terraform-google-modules/terraform-google-group)<br><br> | array(object) | false | - | - |
| groups.customer_id | Customer ID of the organization to create the group in.              See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>              for how to obtain it.<br><br> | string | true | - | - |
| groups.description | Description of the group.<br><br> | string | false | - | - |
| groups.display_name | Display name of the group.<br><br> | string | false | - | - |
| groups.id | Email address of the group.<br><br> | string | true | - | - |
| groups.owners | Owners of the group.<br><br> | array(string) | false | - | - |
| healthcare_datasets | [Module](https://github.com/terraform-google-modules/terraform-google-healthcare)<br><br> | array() | false | - | - |
| healthcare_datasets.consent_stores | Consent stores to create.<br><br> | array(object) | false | - | - |
| healthcare_datasets.consent_stores.default_consent_ttl | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_consent_store#default_consent_ttl>.<br><br> | string | false | - | - |
| healthcare_datasets.consent_stores.enable_consent_create_on_update | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_consent_store#enable_consent_create_on_update>.<br><br> | boolean | false | - | - |
| healthcare_datasets.consent_stores.iam_members | IAM member to grant access for.<br><br> | array(object) | false | - | - |
| healthcare_datasets.consent_stores.iam_members.member | Member to grant acess to role.<br><br> | string | true | - | - |
| healthcare_datasets.consent_stores.iam_members.role | IAM role to grant.<br><br> | string | true | - | - |
| healthcare_datasets.consent_stores.labels | Labels to set on the consent store. See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_consent_store#labels><br><br> | object | false | - | - |
| healthcare_datasets.consent_stores.name | Name of consent store.<br><br> | string | true | - | - |
| healthcare_datasets.dicom_stores | Dicom stores to create.<br><br> | array(object) | false | - | - |
| healthcare_datasets.dicom_stores.iam_members | IAM member to grant access for.<br><br> | array(object) | false | - | - |
| healthcare_datasets.dicom_stores.iam_members.member | Member to grant acess to role.<br><br> | string | true | - | - |
| healthcare_datasets.dicom_stores.iam_members.role | IAM role to grant.<br><br> | string | true | - | - |
| healthcare_datasets.dicom_stores.labels | Labels to set on the DICOM store.<br><br> | object | false | - | - |
| healthcare_datasets.dicom_stores.name | Name of dicom store.<br><br> | string | true | - | - |
| healthcare_datasets.dicom_stores.notification_config | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_dicom_store#notification_config>.<br><br> | object | false | - | - |
| healthcare_datasets.fhir_stores | FHIR stores to create.<br><br> | array(object) | false | - | - |
| healthcare_datasets.fhir_stores.disable_referential_integrity | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#disable_referential_integrity>.<br><br> | boolean | false | - | - |
| healthcare_datasets.fhir_stores.disable_resource_versioning | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#disable_resource_versioning>.<br><br> | boolean | false | - | - |
| healthcare_datasets.fhir_stores.enable_history_import | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#enable_history_import>.<br><br> | boolean | false | - | - |
| healthcare_datasets.fhir_stores.enable_update_create | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#enable_update_create>.<br><br> | boolean | false | - | - |
| healthcare_datasets.fhir_stores.iam_members | IAM member to grant access for.<br><br> | array(object) | false | - | - |
| healthcare_datasets.fhir_stores.iam_members.member | Member to grant acess to role.<br><br> | string | true | - | - |
| healthcare_datasets.fhir_stores.iam_members.role | IAM role to grant.<br><br> | string | true | - | - |
| healthcare_datasets.fhir_stores.labels | Labels to set on the FHIR store.<br><br> | object | false | - | - |
| healthcare_datasets.fhir_stores.name | Name of FHIR store.<br><br> | string | true | - | - |
| healthcare_datasets.fhir_stores.notification_config | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#notification_config>.<br><br> | object | false | - | - |
| healthcare_datasets.fhir_stores.stream_configs | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#stream_configs>.<br><br> | array(object) | false | - | - |
| healthcare_datasets.fhir_stores.stream_configs.bigquery_destination | <br><br> | object | true | - | - |
| healthcare_datasets.fhir_stores.stream_configs.bigquery_destination.dataset_uri | <br><br> | string | true | - | - |
| healthcare_datasets.fhir_stores.stream_configs.bigquery_destination.schema_config | <br><br> | object | true | - | - |
| healthcare_datasets.fhir_stores.stream_configs.bigquery_destination.schema_config.recursive_structure_depth | <br><br> | integer | true | - | - |
| healthcare_datasets.fhir_stores.stream_configs.bigquery_destination.schema_config.schema_type | <br><br> | string | false | - | - |
| healthcare_datasets.fhir_stores.stream_configs.resource_types | <br><br> | array(string) | false | - | - |
| healthcare_datasets.fhir_stores.version | Version of FHIR store.<br><br> | string | true | - | - |
| healthcare_datasets.healthcare_region | Region to create healthcare dataset in. Can be defined in global data block.<br><br> | string | false | - | - |
| healthcare_datasets.hl7_v2_stores | HL7 V2 stores to create.<br><br> | array(object) | false | - | - |
| healthcare_datasets.hl7_v2_stores.iam_members | IAM member to grant access for.<br><br> | array(object) | false | - | - |
| healthcare_datasets.hl7_v2_stores.iam_members.member | Member to grant acess to role.<br><br> | string | true | - | - |
| healthcare_datasets.hl7_v2_stores.iam_members.role | IAM role to grant.<br><br> | string | true | - | - |
| healthcare_datasets.hl7_v2_stores.labels | Labels to set on the HL7 V2 store.<br><br> | object | false | - | - |
| healthcare_datasets.hl7_v2_stores.name | Name of Hl7 V2 store.<br><br> | string | true | - | - |
| healthcare_datasets.hl7_v2_stores.notification_configs | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_hl7_v2_store#notification_configs>.<br><br> | array(object) | false | - | - |
| healthcare_datasets.hl7_v2_stores.parser_config | See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_hl7_v2_store#parser_config>.<br><br> | object | false | - | - |
| healthcare_datasets.hl7_v2_stores.parser_config.allow_null_header | <br><br> | boolean | false | - | - |
| healthcare_datasets.hl7_v2_stores.parser_config.schema | <br><br> | string | false | - | - |
| healthcare_datasets.hl7_v2_stores.parser_config.segment_terminator | <br><br> | string | false | - | - |
| healthcare_datasets.hl7_v2_stores.parser_config.version | <br><br> | string | false | - | - |
| healthcare_datasets.iam_members | IAM member to grant access for.<br><br> | array(object) | false | - | - |
| healthcare_datasets.iam_members.member | Member to grant acess to role.<br><br> | string | true | - | - |
| healthcare_datasets.iam_members.role | IAM role to grant.<br><br> | string | true | - | - |
| healthcare_datasets.name | Name of healthcare dataset.<br><br> | string | true | - | - |
| iam_members | Map of IAM role to list of members to grant access to the role.<br><br> | object | false | - | - |
| pubsub_topics | [Module](https://github.com/terraform-google-modules/terraform-google-pubsub)<br><br> | array() | false | - | - |
| pubsub_topics.labels | Labels to set on the topic.<br><br> | object | false | - | - |
| pubsub_topics.name | Name of the topic.<br><br> | string | true | - | - |
| pubsub_topics.pull_subscriptions | Pull subscriptions on the topic.<br><br> | array(object) | false | - | - |
| pubsub_topics.pull_subscriptions.ack_deadline_seconds | Deadline to wait for acknowledgement.<br><br> | integer | false | - | - |
| pubsub_topics.pull_subscriptions.name | Name of subscription.<br><br> | string | true | - | - |
| pubsub_topics.push_subscriptions | Push subscriptions on the topic.<br><br> | array(object) | false | - | - |
| pubsub_topics.push_subscriptions.ack_deadline_seconds | Deadline to wait for acknowledgement.<br><br> | integer | false | - | - |
| pubsub_topics.push_subscriptions.name | Name of subscription.<br><br> | string | true | - | - |
| pubsub_topics.push_subscriptions.push_endpoint | Name of endpoint to push to.<br><br> | string | false | - | - |
| secrets | [Module](https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html)<br><br> | array() | false | - | - |
| secrets.resource_name | Override for Terraform resource name.              If unset, defaults to normalized secret_id.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| secrets.secret_data | Data of the secret. If unset, should be manually set in the GCP console.<br><br> | string | false | - | - |
| secrets.secret_id | ID of secret.<br><br> | string | true | - | - |
| secrets.secret_locations | Locations to replicate secret. Can be defined in global data block.<br><br> | array(string) | false | - | - |
| service_accounts | [Module](https://www.terraform.io/docs/providers/google/r/google_service_account.html)<br><br> | array() | false | - | - |
| service_accounts.account_id | ID of service account.<br><br> | string | true | - | - |
| service_accounts.description | Description of service account.<br><br> | string | false | - | - |
| service_accounts.display_name | Display name of service account.<br><br> | string | false | - | - |
| service_accounts.resource_name | Override for Terraform resource name.              If unset, defaults to normalized account_id.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| state_bucket | Bucket to store remote state.<br><br> | string | false | - | - |
| state_path_prefix | Path within bucket to store state. Defaults to the template's output_path.<br><br> | string | false | - | - |
| storage_buckets | [Module](https://github.com/terraform-google-modules/terraform-google-cloud-storage/tree/master/modules/simple_bucket)<br><br> | array() | false | - | - |
| storage_buckets.iam_members | IAM member to grant access for.<br><br> | array(object) | false | - | - |
| storage_buckets.iam_members.member | Member to grant acess to role.<br><br> | string | true | - | - |
| storage_buckets.iam_members.role | IAM role to grant.<br><br> | string | true | - | - |
| storage_buckets.labels | Labels to set on the bucket.<br><br> | object | false | - | - |
| storage_buckets.lifecycle_rules | Lifecycle rules configuration for the bucket.<br><br> | array(object) | false | - | - |
| storage_buckets.lifecycle_rules.action | The Lifecycle Rule's action configuration.<br><br> | object | false | - | - |
| storage_buckets.lifecycle_rules.action.storage_class | (Required if action type is SetStorageClass)                        The target Storage Class of objects affected by this Lifecycle Rule.<br><br> | string | false | - | - |
| storage_buckets.lifecycle_rules.action.type | Type of action. Supported values: Delete and SetStorageClass.<br><br> | string | false | - | - |
| storage_buckets.lifecycle_rules.condition | The Lifecycle Rule's condition configuration.<br><br> | object | false | - | - |
| storage_buckets.lifecycle_rules.condition.age | Minimum age of an object in days.<br><br> | integer | false | - | - |
| storage_buckets.lifecycle_rules.condition.created_before | Creation date of an object in RFC 3339 (e.g. 2017-06-13).<br><br> | string | false | - | - |
| storage_buckets.lifecycle_rules.condition.matches_storage_class | Storage Class of objects.<br><br> | string | false | - | - |
| storage_buckets.lifecycle_rules.condition.num_newer_versions | Relevant only for versioned objects.                        The number of newer versions of an object."<br><br> | integer | false | - | - |
| storage_buckets.lifecycle_rules.condition.with_state | Match to live and/or archived objects.<br><br> | string | false | - | - |
| storage_buckets.name | Name of storage bucket.<br><br> | string | false | - | - |
| storage_buckets.resource_name | Override for Terraform resource name.              If unset, defaults to normalized name.              Normalization will make all characters alphanumeric with underscores.<br><br> | string | false | - | - |
| storage_buckets.retention_policy | Configuration of the bucket's data retention policy for how long              objects in the bucket should be retained.<br><br> | object | false | - | - |
| storage_buckets.retention_policy.is_locked | If set to true, the bucket will be                  [locked](https://cloud.google.com/storage/docs/bucket-lock#overview)                  and permanently restrict edits to the bucket's retention                  policy. Caution: Locking a bucket is an irreversible action.                  Defaults to false.<br><br> | boolean | false | - | - |
| storage_buckets.retention_policy.retention_period | The period of time, in seconds, that objects in the bucket                  must be retained and cannot be deleted, overwritten, or                  archived. The value must be less than 2,147,483,647 seconds.<br><br> | number | false | - | - |
| storage_buckets.storage_location | Location to create the storage bucket. Can be defined in global data block.<br><br> | string | false | - | - |
| terraform_addons | Additional Terraform configuration for the project deployment.        Can be used to support arbitrary resources not supported in the following list.        For schema see ./deployment.hcl.<br><br> | object | false | - | - |
