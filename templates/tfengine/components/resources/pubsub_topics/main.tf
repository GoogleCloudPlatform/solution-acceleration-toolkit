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

{{range .pubsub_topics}}
module "{{resourceName . "name"}}" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 1.6.0"

  topic        = "{{.name}}"
  project_id   = {{- if get $.project "exists" false}} "{{$.project.project_id}}" {{- else}} module.project.project_id {{end}}

  {{if $labels := merge (get $ "labels") (get . "labels") -}}
  topic_labels = {
    {{range $k, $v := $labels -}}
    {{$k}} = "{{$v}}"
    {{end -}}
  }
  {{end -}}

  {{hclField . "pull_subscriptions" -}}
  {{hclField . "push_subscriptions" -}}
  {{- if not (get $.project "exists" false)}}
  depends_on =[
    module.project
  ]
  {{end -}}
}
{{end -}}
