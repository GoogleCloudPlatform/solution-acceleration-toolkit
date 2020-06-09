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
  recipe_path = "../deployment/terragrunt.hcl"
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
