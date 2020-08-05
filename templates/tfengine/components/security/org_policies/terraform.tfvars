# Copyright 2020 Google LLC
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
{{if index . "allowed_policy_member_customer_ids"}}
allowed_policy_member_customer_ids = [
  {{- range .allowed_policy_member_customer_ids}}
  "{{.}}",
  {{- end}}
]
{{- end}}
{{- if index . "allowed_shared_vpc_host_projects"}}
allowed_shared_vpc_host_projects = [
  {{- range .allowed_shared_vpc_host_projects}}
  "{{.}}",
  {{- end}}
]
{{- end}}
{{- if index . "allowed_trusted_image_projects"}}
allowed_trusted_image_projects = [
  {{- range .allowed_trusted_image_projects}}
  "{{.}}",
  {{- end}}
]
{{- end}}
{{- if index . "allowed_public_vms"}}
allowed_public_vms = [
  {{- range .allowed_public_vms}}
  "{{.}}",
  {{- end}}
]
{{- end}}
{{- if index . "allowed_ip_forwarding_vms"}}
allowed_ip_forwarding_vms = [
  {{- range .allowed_ip_forwarding_vms}}
  "{{.}}",
  {{- end}}
]
{{- end}}
