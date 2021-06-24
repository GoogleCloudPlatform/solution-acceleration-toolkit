# Audit Recipe

<!-- These files are auto generated -->

## Properties
| Property 	| Description 						| Type 	   			   | Required			   		   | Default             | Pattern 			 			 |
| --------- | ----------------------- | ---------------- | --------------------- | ------------------- | ------------------- |
| additional_filters | Additional filters for log collection and export. List entries will be        concatenated by "OR" operator. Refer to        <https://cloud.google.com/logging/docs/view/query-library> for query syntax.        Need to escape \ and " to preserve them in the final filter strings.        See example usages under "examples/tfengine/".        Logs with filter "logName:\"logs/cloudaudit.googleapis.com\"" is always enabled.<br><br> | array(string) | false | - | - |
| auditors_group | This group will be granted viewer access to the audit log dataset and        bucket as well as security reviewer permission on the root resource        specified.<br><br> | string | false | - | - |
| bigquery_location | Location of logs bigquery dataset.<br><br> | string | false | - | - |
| logs_bigquery_dataset | Bigquery Dataset to host audit logs for 1 year. Useful for querying recent activity.<br><br> | object | false | - | - |
| logs_bigquery_dataset.dataset_id | ID of Bigquery Dataset.<br><br> | string | false | - | - |
| logs_bigquery_dataset.sink_name | Name of the logs sink, default to "bigquery-audit-logs-sink".<br><br> | string | false | - | - |
| logs_storage_bucket | GCS bucket to host audit logs for 7 years. Useful for HIPAA audit log retention requirements.<br><br> | object | false | - | - |
| logs_storage_bucket.name | Name of GCS bucket.<br><br> | string | false | - | - |
| logs_storage_bucket.sink_name | Name of the logs sink, default to "storage-audit-logs-sink".<br><br> | string | false | - | - |
| parent_id | ID of parent GCP resource to apply the policy.        Can be one of the organization ID or folder ID according to parent_type.<br><br> | string | false | - | ^[0-9]{8,25}$ |
| parent_type | Type of parent GCP resource to apply the policy.        Must be one of 'organization' or 'folder'."<br><br> | string | false | - | ^organization|folder$ |
| project | Config of project to host auditing resources<br><br> | object | false | - | - |
| project.project_id | ID of project.<br><br> | string | false | - | ^[a-z][a-z0-9\-]{4,28}[a-z0-9]$ |
| storage_location | Location of logs storage bucket.<br><br> | string | false | - | - |
