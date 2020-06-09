# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

template "terragrunt" {
  recipe_path = "../terraform/terragrunt.hcl"
  data = {
    vars = [{
      name =  "project_id"
      type = "string"
    }]
    deps = [{
      name = "project"
      path = "../project"
      mock_outputs = {
        project_id = "mock-project"
      }
    }]
    inputs = {
      project_id = "$${dependency.project.outputs.project_id}"
    }
  }
}

{{if has . "bastion_hosts"}}
template "bastion_hosts" {
  component_path = "../../components/project/bastion_hosts"
}
{{end}}

{{if has . "bigquery_datasets"}}
template "bigquery_datasets" {
  component_path = "../../components/project/bigquery_datasets"
}
{{end}}

{{if has . "cloud_sql_instances"}}
template "cloud_sql_instances" {
  component_path = "../../components/project/cloud_sql_instances"
}
{{end}}

{{if has . "compute_networks"}}
template "compute_networks" {
  component_path = "../../components/project/compute_networks"
}
{{end}}

{{if has . "compute_routers"}}
template "compute_routers" {
  component_path = "../../components/project/compute_routers"
}
{{end}}

{{if has . "iam_members"}}
template "iam_members" {
  component_path = "../../components/project/iam_members"
}
{{end}}

{{if has . "storage_buckets"}}
template "storage_buckets" {
  component_path = "../../components/project/storage_buckets"
}
{{end}}

{{if has . "gke_clusters"}}
template "gke_clusters" {
  component_path = "../../components/project/gke_clusters"
}
{{end}}

{{if has . "healthcare_datasets"}}
template "healthcare_datasets" {
  component_path = "../../components/project/healthcare_datasets"
}
{{end}}

{{if has . "secrets"}}
template "secrets" {
  component_path = "../../components/org/secrets"
}
{{end}}

{{if has . "service_accounts"}}
template "service_accounts" {
  component_path = "../../components/project/service_accounts"
}
{{end}}
