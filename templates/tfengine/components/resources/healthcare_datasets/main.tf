{{- /* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

{{range get . "healthcare_datasets"}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/healthcare/google"
  version = "~> 2.2.1"

  name     = "{{.name}}"
  project  = module.project.project_id
  location = "{{get . "healthcare_location" $.healthcare_location}}"

  {{hclField . "iam_members" -}}

  {{if has . "consent_stores" -}}
  consent_stores = [
    {{range .consent_stores -}}
    {
      name = "{{.name}}"
      {{hclField . "iam_members" -}}
      {{hclField . "enable_consent_create_on_update" -}}
      {{hclField . "default_consent_ttl" -}}

      {{if $labels := merge (get $ "labels") (get . "labels") -}}
      labels = {
        {{hcl $labels}}
      }
      {{end -}}
    },
    {{end -}}
  ]
  {{end -}}

  {{if has . "dicom_stores" -}}
  dicom_stores = [
    {{range .dicom_stores -}}
    {
      name = "{{.name}}"
      {{hclField . "iam_members" -}}

      {{if has . "notification_config" -}}
      notification_config = {
        {{hcl .notification_config}}
      }
      {{end -}}

      {{if $labels := merge (get $ "labels") (get . "labels") -}}
      labels = {
        {{range $k, $v := $labels -}}
        {{$k}} = "{{$v}}"
        {{end -}}
      }
      {{end -}}
    },
    {{end -}}
  ]
  {{end -}}

  {{- if has . "fhir_stores" -}}
  fhir_stores = [
    {{range .fhir_stores -}}
    {
      name    = "{{.name}}"
      version = "{{.version}}"

      {{hclField . "enable_update_create" -}}
      {{hclField . "disable_referential_integrity" -}}
      {{hclField . "disable_resource_versioning" -}}
      {{hclField . "enable_history_import" -}}
      {{hclField . "complex_data_type_reference_parsing" -}}

      {{hclField . "iam_members" -}}

      {{if has . "notification_configs" -}}
      notification_configs = [
        {{range $k, $v := .notification_configs -}}
        {
          pubsub_topic = "{{$v.pubsub_topic}}"
          {{hclField $v "send_full_resource" -}}
	  {{hclField $v "send_previous_resource_on_delete" -}}
        },
        {{end -}}
      ]
      {{end -}}

      {{if has . "stream_configs" -}}
      stream_configs = [
        {{range $k, $v := .stream_configs -}}
        {
          bigquery_destination = {
            dataset_uri = "{{$v.bigquery_destination.dataset_uri}}"
            schema_config = {
              recursive_structure_depth = "{{$v.bigquery_destination.schema_config.recursive_structure_depth}}"
              schema_type = "{{$v.bigquery_destination.schema_config.schema_type}}"
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
              {{if has .bigquery_destination.schema_config "last_updated_partition_config" -}}
	      last_updated_partition_config = {
                {{if has .bigquery_destination.schema_config.last_updated_partition_config "expiration_ms" -}}
                expiration_ms = "{{$v.bigquery_destination.schema_config.last_updated_partition_config.expiration_ms}}"
		{{end -}}
		{{hclField .bigquery_destination.schema_config.last_updated_partition_config "type" -}}
=======
              {{if has . "last_updated_partition_config" -}}
              last_updated_partition_config = {
=======
              {{hclsField $v.bigquery_destination.schema_config "last_updated_partition_config" -}}
	      last_updated_partition_config = {
>>>>>>> e7adc2e (make last_updated_partition_config as optional)
                {{hcl $v.bigquery_destination.schema_config.last_updated_partition_config}}
>>>>>>> 2d05520 (correct lastUpdatedPartitionConfig as optional)
=======
              {{if has $v.bigquery_destination.schema_config "last_updated_partition_config" -}}
	      last_updated_partition_config = {
                {{hclsField $v.bigquery_destination.schema_config "last_updated_partition_config" -}}
>>>>>>> 35d3004 (update last_updated_partition_config check)
              }
	      {{end -}}
	    }
          }
          {{hclField $v "resource_types" -}}
        },
        {{end -}}
      ]
      {{end -}}


      {{if $labels := merge (get $ "labels") (get . "labels") -}}
      labels = {
        {{range $k, $v := $labels -}}
        {{$k}} = "{{$v}}"
        {{end -}}
      }
      {{end -}}
    },
    {{end -}}
  ]
  {{end -}}

  {{if has . "hl7_v2_stores" -}}
  hl7_v2_stores = [
    {{range .hl7_v2_stores -}}
    {
      name = "{{.name}}"
      {{hclField . "iam_members" -}}
      {{hclField . "notification_configs" -}}

      {{if has . "parser_config" -}}
      parser_config = {
        {{hclField .parser_config "allow_null_header" -}}
        {{hclField .parser_config "segment_terminator" -}}
        {{hclField .parser_config "version" -}}
        {{if has .parser_config "schema" -}}
        schema = <<EOF
{{.parser_config.schema -}}
        EOF
        {{- else if has .parser_config "schema_file" -}}
        schema = templatefile("{{.parser_config.schema_file -}}", {})
        {{- end}}
      }
      {{end -}}

      {{if $labels := merge (get $ "labels") (get . "labels") -}}
      labels = {
        {{range $k, $v := $labels -}}
        {{$k}} = "{{$v}}"
        {{end -}}
      }
      {{end -}}
    },
    {{end -}}
  ]
  {{end -}}

  depends_on = [
    module.project
  ]
}
{{end -}}
