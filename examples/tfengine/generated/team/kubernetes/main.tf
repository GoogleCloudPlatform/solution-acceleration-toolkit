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

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = ">= 3.0"
    google-beta = ">= 3.0"
    kubernetes  = "~> 2.10"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "kubernetes"
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = "us-central1"
  project  = module.project.project_id
}

provider "kubernetes" {
  token                  = data.google_client_config.default.access_token
  host                   = data.google_container_cluster.gke_cluster.endpoint
  client_certificate     = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0.0"

  project_id    = "example-prod-apps"
  activate_apis = []
}

resource "kubernetes_service_account" "ksa" {
  metadata {
    name      = "ksa"
    namespace = "namespace"
    annotations = {
      "iam.gke.io/gcp-service-account" = "runner@${module.project.project_id}.iam.gserviceaccount.com"
    }
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "namespace"
    labels = {
      env = "prod"
    }
    annotations = {
      name = "namespace"
    }
  }
}

module "workload_identity_namespace" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version    = "36.3.0"
  project_id = module.project.project_id
  name       = "runner"

  use_existing_gcp_sa = true
  gcp_sa_name         = "runner"

  use_existing_k8s_sa = true
  # The KSA is annotated as part the KSA resource. It bears the "iam.gke.io/gcp-service-account" annotation.
  annotate_k8s_sa = false
  namespace       = "namespace"
  k8s_sa_name     = "ksa"
  cluster_name    = "gke-cluster"
  location        = "us-central1"
}

