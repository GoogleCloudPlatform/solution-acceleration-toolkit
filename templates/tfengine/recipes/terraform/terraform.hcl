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

template "terraform" {
  component_path = "../../components/terraform/main"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}

{{if or (has . "vars") (has . "terraform_addons.vars")}}
template "vars" {
  component_path = "../../components/terraform/variables"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}

{{if or (has . "outputs") (has . "terraform_addons.outputs")}}
template "outputs" {
  component_path = "../../components/terraform/outputs"
  {{if has . "terraform_addons"}}
  flatten {
    key = "terraform_addons"
  }
  {{end}}
}
{{end}}
