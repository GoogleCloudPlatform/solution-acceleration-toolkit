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

template "base" {
  recipe_path = "./base.hcl"
  flatten {
    key = "devops"
  }
}

{{if has . "audit"}}
template "audit" {
  recipe_path = "./audit.hcl"
  output_path = "./live"
  flatten {
    key = "audit"
  }
}
{{end}}

{{if has . "monitor"}}
template "monitor" {
  recipe_path = "./monitor.hcl"
  output_path = "./live"
  flatten {
    key = "monitor"
  }
}
{{end}}

{{if has . "org_policies"}}
template "org_policies" {
  recipe_path = "./org_policies.hcl"
  output_path = "./live"
  flatten {
    key = "org_policies"
  }
}
{{end}}

{{if has . "cicd"}}
template "cicd_manual" {
  component_path = "../../components/cicd/manual"
  output_path    = "./cicd"
  flatten {
    key = "cicd"
  }
}

template "cicd_auto" {
  component_path = "../../components/cicd/auto"
  output_path    = "./live/cicd"
  flatten {
    key = "cicd"
  }
}
{{end}}
