# Recipe for resources within projects.

## Properties

### access.group_by_email

An email address of a Google Group to grant access to.


Type: string

### access.role

Role to grant.


Type: string

### access.special_group

A special group to grant access to.


Type: string

### access.user_by_email

An email address of a user to grant access to.


Type: string

### action.storage_class

(Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule.


Type: string

### action.type

Type of action. Supported values: Delete and SetStorageClass.


Type: string

### admission_whitelist_patterns.name_pattern

An image name pattern to whitelist, in the form registry/path/to/image.
This supports a trailing * as a wildcard, but this is allowed only in text after the registry/ part."



Type: string

### bastion_hosts

https://github.com/terraform-google-modules/terraform-google-bastion-host


Type: array(object)

### bastion_hosts.compute_region

Region to create bastion host in. Can be defined in global data block.


Type: string

### bastion_hosts.compute_zone

Zone to create bastion host in. Can be defined in global data block.


Type: string

### bastion_hosts.image_family

Family of compute image to use.


Type: string

### bastion_hosts.image_project

Project of compute image to use.


Type: string

### bastion_hosts.members

Members who can access the bastion host.


Type: array(string)

### bastion_hosts.name

Name of bastion host.


Type: string

### bastion_hosts.network

Name of the bastion host's network.


Type: string

### bastion_hosts.network_project_id

Name of network project. If unset, will use the current project.


Type: string

### bastion_hosts.scopes

Scopes to grant. If unset, will grant access to all cloud platform scopes.


Type: array(string)

### bastion_hosts.startup_script

Script to run on startup. Can be multi-line.


Type: string

### bastion_hosts.subnet

Name of the bastion host's subnet.


Type: string

### bigquery_datasets

https://github.com/terraform-google-modules/terraform-google-bigquery


Type: array(object)

### bigquery_datasets.access

Access for this bigquery dataset.
Each object should contain exactly one of the following keys:
- group_by_email
- user_by_email
- special_group



Type: array(object)

### bigquery_datasets.bigquery_location

Location to create the bigquery dataset. Can be defined in global data block.


Type: string

### bigquery_datasets.dataset_id

ID of bigquery dataset.


Type: string

### bigquery_datasets.default_table_expiration_ms

Expiration in milliseconds.


Type: integer

### bigquery_datasets.resource_name

Override for Terraform resource name. If unset, defaults to normalized dataset_id.
Normalization will make all characters alphanumeric with underscores.



Type: string

### binary_authorization

A policy for container image binary authorization.


Type: object

### binary_authorization.admission_whitelist_patterns

A whitelist of image patterns to exclude from admission rules.


Type: array(object)

### cloud_sql_instances

https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql


Type: array(object)

### cloud_sql_instances.cloud_sql_region

Region to create cloud sql instance in. Can be defined in global data block.


Type: string

### cloud_sql_instances.cloud_sql_zone

Zone to reate cloud sql instance in. Can be defined in global data block.


Type: string

### cloud_sql_instances.name

Name of the cloud sql instance.


Type: string

### cloud_sql_instances.network

Name of the network.


Type: string

### cloud_sql_instances.network_project_id

Name of network project. If unset, will use the current project.


Type: string

### cloud_sql_instances.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### cloud_sql_instances.type

Type of the cloud sql instance. Currently only supports 'mysql'.


Type: string

### cloud_sql_instances.user_name

Default user name.


Type: string

### cloud_sql_instances.user_password

Default user password.


Type: string

### compute_instance_templates

https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template


Type: array(object)

### compute_instance_templates.disk_size_gb

Disk space to set for the instance template.


Type: integer

### compute_instance_templates.disk_type

Type of disk to use for the instance template.


Type: string

### compute_instance_templates.enable_shielded_vm

Whether to enable shielded VM. Defaults to true.


Type: boolean

### compute_instance_templates.image_family

Family of compute image to use.


Type: string

### compute_instance_templates.image_project

Project of compute image to use.


Type: string

### compute_instance_templates.instances

https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/compute_instance


Type: array(object)

### compute_instance_templates.name_prefix

Name prefix of the instance template.


Type: string

### compute_instance_templates.network_project_id

Name of network project. If unset, will use the current project.


Type: string

### compute_instance_templates.preemptible

Whether the instance template can be preempted. Defaults to false.


Type: boolean

### compute_instance_templates.resource_name

Override for Terraform resource name. If unset, defaults to normalized name_prefix.
Normalization will make all characters alphanumeric with underscores.



Type: string

### compute_instance_templates.service_account

Email of service account to attach to this instance template.


Type: string

### compute_instance_templates.subnet

Name of the the instance template's subnet.


Type: string

### compute_networks

https://github.com/terraform-google-modules/terraform-google-network


Type: array()

### compute_networks.name

Name of network.


Type: string

### compute_networks.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### compute_networks.subnets

Subnetworks within the network.


Type: array(object)

### compute_routers

https://github.com/terraform-google-modules/terraform-google-cloud-router


Type: array()

### compute_routers.compute_region

Region to create subnet in. Can be defined in global data block.


Type: string

### compute_routers.name

Name of router.


Type: string

### compute_routers.nats

NATs to attach to the router.


Type: array(object)

### compute_routers.network

Name of network the router belongs to.


Type: string

### compute_routers.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### condition.age

Minimum age of an object in days to satisfy this condition.


Type: integer

### condition.created_before

Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.


Type: string

### condition.matches_storage_class

Storage Class of objects to satisfy this condition.


Type: string

### condition.num_newer_versions

Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.


Type: integer

### condition.with_state

Match to live and/or archived objects.


Type: string

### dicom_stores.iam_members

IAM member to grant access for.


Type: array(object)

### dicom_stores.name

Name of dicom store.


Type: string

### dns_zones

https://github.com/terraform-google-modules/terraform-google-cloud-dns


Type: array(object)

### dns_zones.domain

Domain of DNS zone. Must end with period.


Type: string

### dns_zones.name

Name of DNS zone.




### dns_zones.record_sets

Records managed by the DNS zone.


Type: array(object)

### dns_zones.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### dns_zones.type

Type of DNS zone.


Type: string

### fhir_stores.iam_members

IAM member to grant access for.


Type: array(object)

### fhir_stores.name

Name of FHIR store.


Type: string

### fhir_stores.version

Version of FHIR store.


Type: string

### gke_clusters

https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant


Type: array(object)

### gke_clusters.gke_region

Region to create GKE cluster in. Can be defined in global data block.


Type: string

### gke_clusters.ip_range_pods_name

Name of the secondary subnet ip range to use for pods.


Type: string

### gke_clusters.ip_range_services_name

Name of the secondary subnet range to use for services.


Type: string

### gke_clusters.master_authorized_networks

List of master authorized networks. If none are provided, disallow external
access (except the cluster node IPs, which GKE automatically allows).



Type: array(object)

### gke_clusters.master_ipv4_cidr_block

IP range in CIDR notation to use for the hosted master network.


Type: string

### gke_clusters.name

Name of GKE cluster.


Type: string

### gke_clusters.network

Name of the GKE cluster's network.


Type: string

### gke_clusters.network_project_id

Name of network project. If unset, will use the current project.


Type: string

### gke_clusters.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### gke_clusters.subnet

Name of the GKE cluster's subnet.


Type: string

### healthcare_datasets

https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql


Type: array()

### healthcare_datasets.dicom_stores

Dicom stores to create.


Type: array(object)

### healthcare_datasets.fhir_stores

FHIR stores to create.


Type: array(object)

### healthcare_datasets.healthcare_region

Region to create healthcare dataset in. Can be defined in global data block.


Type: string

### healthcare_datasets.hl7_v2_stores

HL7 V2 stores to create.


Type: array(object)

### healthcare_datasets.iam_members

IAM member to grant access for.


Type: array(object)

### healthcare_datasets.name

Name of healthcare dataset.


Type: string

### hl7_v2_stores.iam_members

IAM member to grant access for.


Type: array(object)

### hl7_v2_stores.name

Name of Hl7 V2 store.


Type: string

### iam_members

Map of IAM role to list of members to grant access to the role.


Type: object

### iam_members.member

Member to grant acess to role.


Type: string

### iam_members.role

IAM role to grant.


Type: string

### instances.name

Name of instance.


Type: string

### instances.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### lifecycle_rules.action




Type: object

### lifecycle_rules.condition




Type: object

### master_authorized_networks.cidr_block

CIDR block of the master authorized network.


Type: string

### master_authorized_networks.display_name

Display name of the master authorized network.


Type: string

### nats.name

Name of NAT.


Type: string

### nats.source_subnetwork_ip_ranges_to_nat

How NAT should be configured per Subnetwork.


Type: string

### nats.subnetworks

Subnet NAT configurations. Only applicable if 'source_subnetwork_ip_ranges_to_nat' is 'LIST_OF_SUBNETWORKS'.


Type: array(object)

### pubsub_topics

https://github.com/terraform-google-modules/terraform-google-pubsub


Type: array()

### pubsub_topics.name

Name of the topic.


Type: string

### pubsub_topics.pull_subscriptions

Pull subscriptions on the topic.


Type: array(object)

### pubsub_topics.push_subscriptions

Push subscriptions on the topic.


Type: array(object)

### pull_subscriptions.ack_deadline_seconds

Deadline to wait for acknowledgement.


Type: integer

### pull_subscriptions.name

Name of subscription.


Type: string

### push_subscriptions.ack_deadline_seconds

Deadline to wait for acknowledgement.


Type: integer

### push_subscriptions.name

Name of subscription.


Type: string

### push_subscriptions.push_endpoint

Name of endpoint to push to.


Type: string

### record_sets.name

Name of record set.


Type: string

### record_sets.records

Data of the record set.


Type: array(string)

### record_sets.ttl

Time to live of this record set, in seconds.


Type: integer

### record_sets.type

Type of record set.


Type: string

### secondary_ranges.ip_range

IP range for the secondary range.


Type: string

### secondary_ranges.name

Name of secondary range.


Type: string

### secrets

https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html


Type: array()

### secrets.locations

Locations to replicate secret. If unset, will automatically replicate.


Type: array(string)

### secrets.resource_name

Override for Terraform resource name. If unset, defaults to normalized secret_id.
Normalization will make all characters alphanumeric with underscores.



Type: string

### secrets.secret_data

Data of the secret. If unset, should be manually set in the GCP console.


Type: string

### secrets.secret_id

ID of secret.


Type: string

### service_accounts

https://www.terraform.io/docs/providers/google/r/google_service_account.html


Type: array()

### service_accounts.account_id

ID of service account.


Type: string

### service_accounts.resource_name

Override for Terraform resource name. If unset, defaults to normalized account_id.
Normalization will make all characters alphanumeric with underscores.



Type: string

### storage_buckets

https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql


Type: array()

### storage_buckets.iam_members

IAM member to grant access for.


Type: array(object)

### storage_buckets.lifecycle_rules

Lifecycle rules configuration for the bucket.


Type: array(object)

### storage_buckets.name

Name of storage bucket.


Type: string

### storage_buckets.resource_name

Override for Terraform resource name. If unset, defaults to normalized name.
Normalization will make all characters alphanumeric with underscores.



Type: string

### storage_buckets.storage_location

Location to create the storage bucket. Can be defined in global data block.


Type: string

### subnets.cloud_sql_private_service_access

Whether to enable Cloud SQL private service access. Defaults to false.


Type: boolean

### subnets.compute_region

Region to create subnet in. Can be defined in global data block.


Type: string

### subnets.ip_range

IP range of the subnet.


Type: string

### subnets.name

Name of subnet.


Type: string

### subnets.secondary_ranges

Secondary ranges of the subnet.


Type: array(object)

### subnetworks.name

Name of subnet.


Type: string

### subnetworks.secondary_ip_range_names

List of the secondary ranges of the subnetwork that are allowed to use NAT. Only applicable if one of the values in 'source_ip_ranges_to_nat' is 'LIST_OF_SECONDARY_IP_RANGES'.


Type: array(string)

### subnetworks.source_ip_ranges_to_nat

List of options for which source IPs in the subnetwork should have NAT enabled.


Type: array(string)

### terraform_addons

Additional Terraform configuration for the project deployment.
Can be used to support arbitrary resources not supported in the following list.
For schema see ./deployment.hcl.



Type: object

