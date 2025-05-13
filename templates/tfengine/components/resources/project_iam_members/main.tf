{{/* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */}}
module "project_iam_members" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "~> 8.1.0"

  projects = [module.project.project_id]
  mode     = "additive"

  bindings = {
    {{range $role, $members := .iam_members -}}
    "{{$role}}" = [
      {{range $members -}}
      "{{.}}",
      {{end -}}
    ],
    {{end -}}
  }
}
