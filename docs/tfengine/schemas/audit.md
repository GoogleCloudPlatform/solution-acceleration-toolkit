# Audit Recipe

<!-- These files are auto generated -->

## Properties

### additional_filters

Additional filters for log collection and export. List entries will be
concatenated by "OR" operator. Refer to
<https://cloud.google.com/logging/docs/view/query-library> for query syntax.
Need to escape \ and " to preserve them in the final filter strings.
See example usages under "examples/tfengine/".
Logs with filter "logName:\"logs/cloudaudit.googleapis.com\"" is always enabled.

Type: array(string)

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

### logs_bigquery_dataset.sink_name

Name of the logs sink, default to "bigquery-audit-logs-sink".

Type: string

### logs_storage_bucket

GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements.

Type: object

### logs_storage_bucket.name

Name of GCS bucket.

Type: string

### logs_storage_bucket.sink_name

Name of the logs sink, default to "storage-audit-logs-sink".

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
