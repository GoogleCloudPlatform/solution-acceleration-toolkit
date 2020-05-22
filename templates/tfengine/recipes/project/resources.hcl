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

templates {
  recipe_path= "../terraform/terraform.hcl"
  data = {
    vars = [{
      name =  "project_id"
      type = "string"
    }]
    deps = [{
      name = "project"
      path = "../project"
      mock_outputs = {
        project_id = "\"mock-project\""
      }
    }]
    inputs = {
      project_id = "dependency.project.outputs.project_id"
    }
  }
}

{{if has . "bigquery_datasets"}}
templates {
  component_path = "../../components/project/bigquery_datasets"
}
{{end}}

{{if has . "compute_networks"}}
templates {
  component_path = "../../components/project/compute_networks"
}
{{end}}

{{if has . "storage_buckets"}}
templates {
  component_path = "../../components/project/storage_buckets"
}
{{end}}

{{if has . "gke_clusters"}}
templates {
  component_path = "../../components/project/gke_clusters"
}
{{end}}

{{if has . "service_accounts"}}
templates {
  component_path = "../../components/project/service_accounts"
}
{{end}}
