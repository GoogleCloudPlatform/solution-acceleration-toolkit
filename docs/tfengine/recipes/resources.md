# Recipe for resources within projects.

## Properties

### bastion_hosts

https://github.com/terraform-google-modules/terraform-google-bastion-host


Type: array

### bigquery_datasets

https://github.com/terraform-google-modules/terraform-google-bigquery


Type: array

### binary_authorization

A policy for container image binary authorization.


Type: object

### binary_authorization.admission_whitelist_patterns

A whitelist of image patterns to exclude from admission rules.


Type: array

### cloud_sql_instances

https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql


Type: array

### compute_instance_templates

https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template


Type: array

### compute_networks

https://github.com/terraform-google-modules/terraform-google-network


Type: array

### compute_routers

https://github.com/terraform-google-modules/terraform-google-cloud-router


Type: array

### dns_zones

https://github.com/terraform-google-modules/terraform-google-cloud-dns


Type: array

### gke_clusters

https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant


Type: array

### healthcare_datasets

https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql


Type: array

### iam_members

Map of IAM role to list of members to grant access to the role.


Type: object

### pubsub_topics

https://github.com/terraform-google-modules/terraform-google-pubsub


Type: array

### secrets

https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html


Type: array

### service_accounts

https://www.terraform.io/docs/providers/google/r/google_service_account.html


Type: array

### storage_buckets

https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql


Type: array

### terraform_addons

Additional Terraform configuration for the project deployment.
Can be used to support arbitrary resources not supported in the following list.
For schema see ./deployment.hcl.



Type: object

