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
    google      = "~> 3.0"
    google-beta = "~> 3.0"
    kubernetes  = "~> 1.0"
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
  project  = "example-prod-apps"
}

provider "kubernetes" {
  alias                  = "gke-alias"
  load_config_file       = false
  token                  = data.google_client_config.default.access_token
  host                   = data.google_container_cluster.gke_cluster.endpoint
  client_certificate     = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_certificate)
  client_key             = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "namespace"
    annotations = {
      name = "namespace"
    }
  }
}


module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.1.0"

  project_id    = "example-prod-apps"
  activate_apis = []
}

resource "kubernetes_service_account" "ksa_ksa-gke" {
  metadata {
    name      = "ksa-gke"
    namespace = "namespace"
    annotations = {
      "iam.gke.io/gcp-service-account" = "runner@example-prod-apps.iam.gserviceaccount.com"
    }
  }
  provider = kubernetes.gke-alias
}

module "workload_identity_namespace" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version    = "16.1.0"
  project_id = "example-prod-apps"
  name       = "runner"

  use_existing_gcp_sa = true
  gcp_sa_name         = "runner"

  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  namespace           = "namespace"
  k8s_sa_name         = "ksa-gke"
  cluster_name        = "gke-cluster"
  location            = "us-central1"
}


