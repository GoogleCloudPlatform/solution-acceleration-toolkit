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

{{- $hasGoogle := false}}
{{- $hasGoogleBeta := false}}
{{- $hasKubernetes := false}}

terraform {
  required_version = ">=0.14"
  required_providers {
{{if has . "providers" -}}
  {{range .providers -}}
    {{.name}} = "{{.version_constraints}}"
    {{if or (eq .name "google") (eq .name "hashicorp/google") -}}
      {{$hasGoogle = true -}}
    {{end -}}
    {{if or (eq .name "google-beta") (eq .name "hashicorp/google-beta") -}}
      {{$hasGoogleBeta = true -}}
    {{end -}}
    {{if or (eq .name "kubernetes") (eq .name "hashicorp/kubernetes") -}}
      {{$hasKubernetes = true -}}
    {{end -}}
  {{end -}}
{{end -}}
    {{if not $hasGoogle -}}
    google      = "~> 3.0"
    {{end -}}
    {{if not $hasGoogleBeta -}}
    google-beta = "~> 3.0"
    {{end -}}
    {{if not $hasKubernetes -}}
    kubernetes  = "~> 1.0"
    {{end -}}
  }
  backend "gcs" {
    bucket = "{{.state_bucket}}"
    prefix = "{{get . "state_path_prefix" .output_path}}"
  }
}

{{if has . "raw_config" -}}
{{.raw_config}}
{{end -}}
