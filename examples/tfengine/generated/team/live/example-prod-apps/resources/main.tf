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
  required_version = "~> 0.12.0"
  required_providers {
    google      = "~> 3.0"
    google-beta = "~> 3.0"
  }
  backend "gcs" {
  }
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
  # Whitelist images from this project.
  admission_whitelist_patterns {
    name_pattern = "gcr.io/$${var.project_id}/*"
  }

  admission_whitelist_patterns {
    name_pattern = "gcr.io/cloudsql-docker/*"
  }
}

module "example_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 3.0.0"

  name_prefix        = "example-instance-template"
  project_id         = var.project_id
  region             = "us-central1"
  subnetwork_project = "example-prod-networks"
  subnetwork         = "example-instance-subnet"

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
}
module "instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "~> 3.0.0"

  hostname           = "instance"
  instance_template  = module.example_instance_template.self_link
  region             = "us-central1"
  subnetwork_project = "example-prod-networks"
  subnetwork         = "example-instance-subnet"
}
module "project_iam_members" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "~> 6.1.0"

  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    "roles/container.viewer" = [
      "group:example-viewers@example.com",
    ],
  }
}

resource "google_service_account" "example_sa" {
  account_id = "example-sa"
  project    = var.project_id
}

