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

storage_bucket_iam_members = {
  {{- if has .iam_members "storage_bucket"}}
  {{range $index, $value := get . "iam_members.storage_bucket"}}
  {{$index}} = {
    bindings = {
      {{range $role, $members := .bindings -}}
      "{{$role}}" = [
        {{range $members -}}
        "{{.}}",
        {{end -}}
      ],
      {{end -}}
    }
    parent_ids = [
      {{- range .parent_ids}}
      "{{.}}",
      {{- end}}
    ]
  },
  {{else -}}
  {
    bindings = {}
    parent_ids = []
  },
  {{end -}}
  {{end -}}
}

project_iam_members = {
  {{- if has .iam_members "project"}}
  {{range $index, $value := get . "iam_members.project"}}
  {{$index}} = {
    bindings = {
      {{range $role, $members := .bindings -}}
      "{{$role}}" = [
        {{range $members -}}
        "{{.}}",
        {{end -}}
      ],
      {{end -}}
    }
    parent_ids = [
      {{- range .parent_ids}}
      "{{.}}",
      {{- end}}
    ]
  },
  {{else -}}
  {
    bindings = {}
    parent_ids = []
  },
  {{end -}}
  {{end -}}
}

folder_iam_members = {
  {{if has .iam_members "folder" -}}
  {{range $index, $value := get . "iam_members.folder"}}
  {{$index}} = {
    bindings = {
      {{range $role, $members := .bindings -}}
      "{{$role}}" = [
        {{range $members -}}
        "{{.}}",
        {{end -}}
      ],
      {{end -}}
    }
    parent_ids = [
      {{- range .parent_ids}}
      "{{.}}",
      {{- end}}
    ]
  },
  {{else -}}
  {
    bindings = {}
    parent_ids = []
  },
  {{end -}}
  {{end -}}
}

organization_iam_members = {
  {{if has .iam_members "organization" -}}
  {{range $index, $value := get . "iam_members.organization"}}
  {{$index}} = {
    bindings = {
      {{range $role, $members := .bindings -}}
      "{{$role}}" = [
        {{range $members -}}
        "{{.}}",
        {{end -}}
      ],
      {{end -}}
    }
    parent_ids = [
      {{- range .parent_ids}}
      "{{.}}",
      {{- end}}
    ]
  },
  {{else -}}
  {
    bindings = {}
    parent_ids = []
  },
  {{end -}}
  {{end -}}
}

service_account_iam_members = {
  {{if has .iam_members "service_account" -}}
  {{range $index, $value := get . "iam_members.service_account"}}
  {{$index}} = {
    bindings = {
      {{range $role, $members := .bindings -}}
      "{{$role}}" = [
        {{range $members -}}
        "{{.}}",
        {{end -}}
      ],
      {{end -}}
    }
    parent_ids = [
      {{- range .parent_ids}}
      "{{.}}",
      {{- end}}
    ]
  },
  {{else -}}
  {
    bindings = {}
    parent_ids = []
  },
  {{end -}}
  {{end -}}
}
