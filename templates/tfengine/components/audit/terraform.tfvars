# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{- $additional_filters := ``}}
{{- range get . "additional_filters"}}
{{- $additional_filters = printf "%s OR %s" $additional_filters .}}
{{- end}}

{{if eq .parent_type "organization" -}}
org_id = "{{.parent_id}}"
{{- else}}
folder = "folders/{{.parent_id}}"
{{- end}}
auditors_group = "{{.auditors_group}}"
additional_filters = "{{$additional_filters}}"
bigquery_location ="{{.bigquery_location}}"
logs_bigquery_dataset = {
  dataset_id = "{{.logs_bigquery_dataset.dataset_id}}"
  sink_name = "{{get .logs_bigquery_dataset "sink_name" "bigquery-audit-logs-sink"}}"
}
logs_storage_bucket = {
  name = "{{.logs_storage_bucket.name}}"
  sink_name = "{{get .logs_storage_bucket "sink_name" "storage-audit-logs-sink"}}"
}
storage_location = "{{.storage_location}}"
