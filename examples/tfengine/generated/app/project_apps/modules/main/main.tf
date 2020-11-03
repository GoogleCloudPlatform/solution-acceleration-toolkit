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
  source = "../../../constants"
}

locals {
  constants = merge(module.constants.values.shared, module.constants.values[var.env])
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google//modules/shared_vpc"
  version = "~> 9.2.0"

  name                    = "${local.constants.project_prefix}-${local.constants.env_code}-apps"
  org_id                  = ""
  folder_id               = local.constants.folder_id
  billing_account         = local.constants.billing_account
  lien                    = true
  default_service_account = "keep"
  skip_gcloud_download    = true

  shared_vpc    = "${local.constants.project_prefix}-${local.constants.env_code}-(get .shared_vpc_attachment.host_project_suffix)"
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
  # Whitelist images from this project.
  admission_whitelist_patterns {
    name_pattern = "gcr.io/${module.project.project_id}/*"
  }

  admission_whitelist_patterns {
    name_pattern = "gcr.io/cloudsql-docker/*"
  }
}

module "example_gke_cluster" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "~> 12.0.0"

  # Required.
  name               = "example-gke-cluster"
  project_id         = module.project.project_id
  region             = local.constants.gke_region
  regional           = true
  network_project_id = "example-prod-networks"

  network                        = "example-network"
  subnetwork                     = "example-gke-subnet"
  ip_range_pods                  = "example-pods-range"
  ip_range_services              = "example-services-range"
  master_ipv4_cidr_block         = "192.168.0.0/28"
  istio                          = true
  skip_provisioners              = true
  enable_private_endpoint        = false
  release_channel                = "STABLE"
  compute_engine_service_account = "gke@example-prod-apps.iam.gserviceaccount.com"
  cluster_resource_labels = {
    type = "no-phi"
  }
}
