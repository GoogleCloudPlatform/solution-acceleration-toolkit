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

terraform {
  required_version = ">=0.14"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "project_apps"
  }
}

resource "google_compute_address" "static" {
  name = "static-ipv4-address"
}

# Create the project and optionally enable APIs, create the deletion lien and add to shared VPC.
# Deletion lien: https://cloud.google.com/resource-manager/docs/project-liens
# Shared VPC: https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#centralize_network_control
module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1.0"

  name            = "example-apps"
  org_id          = ""
  folder_id       = "12345678"
  billing_account = "000-000-000"
  lien            = true
  # Create and keep default service accounts when certain APIs are enabled.
  default_service_account = "keep"
  # Do not create an additional project service account to be used for Compute Engine.
  create_project_sa = false
  # When Kubernetes Engine API is enabled, grant Kubernetes Engine Service Agent the
  # Compute Security Admin role on the VPC host project so it can manage firewall rules.
  # It is a no-op when Kubernetes Engine API is not enabled in the project.
  grant_services_security_admin_role = true

  svpc_host_project_id = "example-prod-networks"
  shared_vpc_subnets = [
    "projects/example-prod-networks/regions/us-central1/subnetworks/example-gke-subnet",
  ]
  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
  ]
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

module "example_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 6.0.0"

  name_prefix        = "example-instance-template"
  project_id         = module.project.project_id
  region             = "us-central1"
  subnetwork_project = "example-prod-networks"
  subnetwork         = "example-instance-subnet"

  source_image_family  = "ubuntu-2004-lts"
  source_image_project = "ubuntu-os-cloud"
  service_account = {
    email  = "${google_service_account.example_sa.email}"
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
  depends_on = [
    module.project
  ]
}

module "instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 6.0.0"

  hostname           = "instance"
  instance_template  = module.example_instance_template.self_link
  region             = "us-central1"
  subnetwork_project = "example-prod-networks"
  subnetwork         = "example-instance-subnet"

  access_config = [
    {
      nat_ip       = "${google_compute_address.static.address}"
      network_tier = "PREMIUM"
    },
  ]

}

module "example_domain" {
  source  = "terraform-google-modules/cloud-dns/google"
  version = "~> 3.1.0"

  name       = "example-domain"
  project_id = module.project.project_id
  domain     = "example-domain.com."
  type       = "public"

  recordsets = [
    {
      name    = "example"
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
  version = "~> 13.0.0"

  providers = {
    kubernetes = kubernetes.gke_cluster
  }

  # Required.
  name               = "gke-cluster"
  project_id         = module.project.project_id
  region             = "us-central1"
  regional           = true
  network_project_id = "example-networks"

  network                        = "example-network"
  subnetwork                     = "example-gke-subnet"
  ip_range_pods                  = "example-pods-range"
  ip_range_services              = "example-services-range"
  master_ipv4_cidr_block         = "192.168.0.0/28"
  skip_provisioners              = true
  enable_private_endpoint        = false
  release_channel                = "STABLE"
  compute_engine_service_account = "gke@example-prod-apps.iam.gserviceaccount.com"
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
  version = "~> 6.4.0"

  projects = [module.project.project_id]
  mode     = "additive"

  bindings = {
    "roles/container.viewer" = [
      "group:example-apps-viewers@example.com",
    ],
  }
}

module "foo_topic" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 1.8.0"

  topic      = "foo-topic"
  project_id = module.project.project_id

  topic_labels = {
    env  = "prod"
    type = "no-phi"
  }
  pull_subscriptions = [
    {
      name = "pull-subscription"
    },
  ]
  push_subscriptions = [
    {
      name          = "push-subscription"
      push_endpoint = "https://example.com"
    },
  ]
  depends_on = [
    module.project
  ]
}

resource "google_service_account" "example_sa" {
  account_id   = "example-sa"
  display_name = "Example Service Account"

  description = "Example Service Account"

  project = module.project.project_id
}
