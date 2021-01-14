# Copyright 2020 Google LLC
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

module "constants" {
  source = "../constants"
}

locals {
  constants = merge(module.constants.values.shared, module.constants.values[var.env])
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/svpc_service_project"
  version = "~> 10.0.2"

  name            = "${local.constants.project_prefix}-${local.constants.env_code}-apps"
  org_id          = ""
  folder_id       = local.constants.folder_id
  billing_account = local.constants.billing_account
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false

  shared_vpc    = "${local.constants.project_prefix}-${local.constants.env_code}-networks"
  activate_apis = ["compute.googleapis.com"]
}
resource "google_binary_authorization_policy" "policy" {
  project = module.project.project_id

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
    name_pattern = "gcr.io/${module.project.project_id}/*"
  }

  admission_whitelist_patterns {
    name_pattern = "gcr.io/cloudsql-docker/*"
  }
}
data "google_client_config" "default" {}


provider "kubernetes" {
  alias                  = "example_gke_cluster"
  load_config_file       = false
  host                   = "https://${module.example_gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.example_gke_cluster.ca_certificate)
}

module "example_gke_cluster" {
  # TODO(https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/issues/695):
  # Pin to stable version once released.
  # source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  # version = "~> 13.0.0"
  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/safer-cluster-update-variant?ref=81b0a9491d51546eedc6c1aabd368dc085c16b5e"

  providers = {
    kubernetes = kubernetes.example_gke_cluster
  }

  # Required.
  name               = "example-gke-cluster"
  project_id         = module.project.project_id
  region             = local.constants.gke_region
  regional           = true
  network_project_id = "example-prod-networks"

  network                 = "example-network"
  subnetwork              = "example-gke-subnet"
  ip_range_pods           = "example-pods-range"
  ip_range_services       = "example-services-range"
  master_ipv4_cidr_block  = "192.168.0.0/28"
  skip_provisioners       = true
  enable_private_endpoint = false
  release_channel         = "STABLE"
  cluster_resource_labels = {
    type = "no-phi"
  }

  depends_on = [
    module.project
  ]
}
