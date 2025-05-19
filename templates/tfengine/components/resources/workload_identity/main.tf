{{- /* Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */ -}}

{{range get . "workload_identity"}}
module "workload_identity_{{resourceName . "namespace"}}" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "36.3.0"
  project_id          = "{{.project_id}}"
  name                = "{{.google_service_account_id}}"

  use_existing_gcp_sa = true
  gcp_sa_name         = "{{.google_service_account_id}}"

  use_existing_k8s_sa = true
  # The KSA is annotated as part the KSA resource. It bears the "iam.gke.io/gcp-service-account" annotation.
  annotate_k8s_sa     = false
  namespace           = "{{.namespace}}"
  k8s_sa_name         = "{{.kubernetes_service_account_name}}"
  cluster_name        = "{{.cluster_name}}"
  location            = "{{.location}}"
}
{{end}}
