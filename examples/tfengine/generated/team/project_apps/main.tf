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
    prefix = "project_apps"
  }
}

resource "google_compute_address" "static" {
  name    = "static-ipv4-address"
  project = module.project[0].project_id
  region  = "us-central1"
}

module "existing_project" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 11.1.0"

  count = var.exists ? 1 : 0

  project_id    = var.project_id
  activate_apis = var.apis
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 11.1.0"

  count = var.exists ? 0 : 1

  name            = var.project_id
  org_id          = var.parent_type == "organization" ? var.parent_id : ""
  folder_id       = var.parent_type == "folder" ? var.parent_id : ""
  billing_account = var.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  enable_shared_vpc_host_project = var.is_shared_vpc_host

  svpc_host_project_id = var.shared_vpc_attachment.host_project_id
  shared_vpc_subnets   = var.shared_vpc_attachment.subnets
  activate_apis        = var.apis

  activate_api_identities = var.api_identities
}
resource "google_binary_authorization_policy" "policy" {
  project = var.project_id

  # Allow Google-built images.
  # See https://cloud.google.com/binary-authorization/docs/policy-yaml-reference#globalpolicyevaluationmode
  global_policy_evaluation_mode = "ENABLE"

  # Block all other images.
  # See https://cloud.google.com/binary-authorization/docs/policy-yaml-reference#defaultadmissionrule
  default_admission_rule {
    evaluation_mode  = "ALWAYS_DENY"
    enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
  }

  # Recommendations from https://cloud.google.com/binary-authorization/docs/policy-yaml-reference#admissionwhitelistpatterns
  admission_whitelist_patterns {
    name_pattern = "gcr.io/google_containers/*"
  }
  admission_whitelist_patterns {
    name_pattern = "gcr.io/google-containers/*"
  }
  admission_whitelist_patterns {
    name_pattern = "k8s.gcr.io/*"
  }
  admission_whitelist_patterns {
    name_pattern = "gke.gcr.io/*"
  }
  admission_whitelist_patterns {
    name_pattern = "gcr.io/stackdriver-agents/*"
  }

  # Not all istio images are added by default in the "google images" policy.
  admission_whitelist_patterns {
    name_pattern = "gke.gcr.io/istio/*"
  }
  admission_whitelist_patterns {
    # The more generic pattern above does not seem to be enough for all images.
    name_pattern = "gke.gcr.io/istio/prometheus/*"
  }

  # Calico images in a new registry.
  admission_whitelist_patterns {
    name_pattern = "gcr.io/projectcalico-org/*"
  }

  # Allow images from this project.
  admission_whitelist_patterns {
    name_pattern = "gcr.io/${var.project_id}/*"
  }

  admission_whitelist_patterns {
    name_pattern = "gcr.io/cloudsql-docker/*"
  }
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 6.6.0"

  name_prefix        = "instance-template"
  project_id         = var.project_id
  region             = "us-central1"
  subnetwork_project = "example-prod-networks"
  subnetwork         = "instance-subnet"

  tags                 = ["service"]
  source_image_family  = "ubuntu-2004-lts"
  source_image_project = "ubuntu-os-cloud"
  service_account = {
    email  = "${google_service_account.runner.email}"
    scopes = ["cloud-platform"]
  }

  enable_shielded_vm = true
  shielded_instance_config = {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  labels = {
    env  = "prod"
    type = "no-phi"
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  depends_on = [
    module.project
  ]
}

module "instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 6.6.0"

  hostname           = "instance"
  instance_template  = module.instance_template.self_link
  region             = "us-central1"
  subnetwork_project = "example-prod-networks"
  subnetwork         = "instance-subnet"

  access_config = [
    {
      nat_ip       = "${google_compute_address.static.address}"
      network_tier = "PREMIUM"
    },
  ]

}

module "domain" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 3.1.0"

  name       = "domain"
  project_id = var.project_id
  domain     = "example.com."
  type       = "public"

  recordsets = [
    {
      name    = "record"
      records = ["142.0.0.0"]
      ttl     = 30
      type    = "A"
    },
  ]
}
data "google_client_config" "default" {}


provider "kubernetes" {
  alias                  = "gke_cluster"
  load_config_file       = false
  host                   = "https://${module.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.ca_certificate)
}

module "gke_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "~> 13.1.0"

  providers = {
    kubernetes = kubernetes.gke_cluster
  }

  # Required.
  name               = "gke-cluster"
  project_id         = var.project_id
  region             = "us-central1"
  regional           = true
  network_project_id = "example-prod-networks"

  network                 = "network"
  subnetwork              = "gke-subnet"
  ip_range_pods           = "pods-range"
  ip_range_services       = "services-range"
  master_ipv4_cidr_block  = "192.168.0.0/28"
  skip_provisioners       = true
  enable_private_endpoint = false
  release_channel         = "STABLE"
  cluster_resource_labels = {
    env  = "prod"
    type = "no-phi"
  }
  node_pools = [
    {
      machine_type = "e2-small"
      name         = "default-node-pool"
    },
  ]

  depends_on = [
    module.project
  ]
}

module "project_iam_members" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 7.2.0"

  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    "roles/storage.objectViewer" = [
      "serviceAccount:${google_service_account.runner.account_id}@example-prod-apps.iam.gserviceaccount.com",
    ],
  }
}

resource "google_service_account" "runner" {
  account_id   = "runner"
  display_name = "Service Account"

  description = "Service Account"

  project = var.project_id
}
