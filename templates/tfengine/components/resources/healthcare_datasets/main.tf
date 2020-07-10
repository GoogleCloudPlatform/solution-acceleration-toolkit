{{- /* Copyright 2020 Google LLC

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
  version = "~> 1.0.0"

  name     = "{{.name}}"
  project  = module.project.project_id
  location = "{{get . "healthcare_location" $.healthcare_location}}"

  {{hclField . "iam_members"}}

  {{if has . "dicom_stores" -}}
  dicom_stores = [
    {{range .dicom_stores -}}
    {
      name = "{{.name}}"
      {{hclField . "iam_members"}}
    }
    {{- end}}
  ]
  {{- end}}

  {{- if has . "fhir_stores"}}
  fhir_stores = [
    {{range .fhir_stores -}}
    {
      name    = "{{.name}}"
      version = "{{.version}}"

      {{hclField . "iam_members" -}}
    }
    {{- end}}
  ]
  {{- end}}

  {{- if has . "hl7_v2_stores"}}
  hl7_v2_stores = [
    {{range .hl7_v2_stores -}}
    {
      name = "{{.name}}"
      {{hclField . "iam_members"}}
    }
    {{- end}}
  ]
  {{- end}}
}
{{- end}}
