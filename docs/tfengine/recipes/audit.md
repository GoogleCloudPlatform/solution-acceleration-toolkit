
# Org Audit Recipe

## Properties

### auditors_group

This group will be granted viewer access to the audit log dataset and
bucket as well as security reviewer permission on the root resource
specified.




### bigquery_location

Location of logs bigquery dataset.



### logs_bigquery_dataset

Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity.



### logs_storage_bucket

GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements.



### parent_id

ID of parent GCP resource to apply the policy: can be one of the organization ID,
folder ID according to parent_type.




### parent_type

Type of parent GCP resource to apply the policy. Must be one of 'organization' or 'folder'.



### project

Config of project to host auditing resources



### storage_location

Location of logs storage bucket.



