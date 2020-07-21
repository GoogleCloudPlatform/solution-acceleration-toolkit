# Audit Recipe

## Properties

### auditors_group

This group will be granted viewer access to the audit log dataset and
bucket as well as security reviewer permission on the root resource
specified.

Type: string

### bigquery_location

Location of logs bigquery dataset.

Type: string

### logs_bigquery_dataset

Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity.

Type: object

### logs_bigquery_dataset.dataset_id

ID of Bigquery Dataset.

Type: string

### logs_storage_bucket

GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements.

Type: object

### logs_storage_bucket.name

Name of GCS bucket.

Type: string

### parent_id

ID of parent GCP resource to apply the policy.
Can be one of the organization ID or folder ID according to parent_type.

Type: string

### parent_type

Type of parent GCP resource to apply the policy.
Must be one of 'organization' or 'folder'."

Type: string

### project

Config of project to host auditing resources

Type: object

### project.project_id

ID of project.

Type: string

### storage_location

Location of logs storage bucket.

Type: string
