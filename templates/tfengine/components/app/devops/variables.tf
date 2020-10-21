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

variable "devops_owners" {
  description = <<EOF
    List of members to transfer ownership of the devops project to.
    NOTE: By default the creating user will be the owner of the project.
    Thus, there should be a group in this list and you must be part of that group, so a group owns the project going forward.
  EOF
  type = list(string)
}

variable "admins_group" {
  description = "Group who will be given admin access on the parent resource (org/folder)."
  type        = string
}
