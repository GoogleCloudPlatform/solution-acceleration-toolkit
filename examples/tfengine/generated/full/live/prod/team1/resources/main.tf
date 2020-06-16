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


module "bastion_vm" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 2.6.0"

  name         = "bastion-vm"
  project      = var.project_id
  zone         = "us-central1-a"
  host_project = var.project_id
  network      = "${module.example_network.network.network.self_link}"
  subnet       = "${module.example_network.subnets["us-central1/example-bastion-subnet"].self_link}"
  image_family = "ubuntu-2004-lts"

  image_project = "ubuntu-os-cloud"

  members = ["group:bastion-accessors@example.com"]

  
  startup_script = <<EOF
sudo apt-get -y update
sudo apt-get -y install mysql-client
sudo wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy
sudo chmod +x /usr/local/bin/cloud_sql_proxy

EOF
}


module "example_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3.0"

  network_name = "example-network"
  project_id   = var.project_id
  subnets = [
    {
      subnet_name            = "example-bastion-subnet"
      subnet_ip              = "10.1.0.0/16"
      subnet_region          = "us-central1"
      subnet_flow_logs       = true
      subnets_private_access = true
    },
    {
      subnet_name            = "example-gke-subnet"
      subnet_ip              = "10.2.0.0/16"
      subnet_region          = "us-central1"
      subnet_flow_logs       = true
      subnets_private_access = true
    },
    
  ]
  secondary_ranges = {
    "example-gke-subnet" = [
      {
        range_name    = "example-pods-range"
        ip_cidr_range = "172.16.0.0/14"
      },
      {
        range_name    = "example-services-range"
        ip_cidr_range = "172.20.0.0/14"
      },
    ],
  }
}
module "cloud_sql_private_service_access_example_network" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
  version = "~> 3.2.0"

  project_id  = var.project_id
  vpc_network = module.example_network.network_name
}
module "example_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.1.0"

  name         = "example-router"
  project      = var.project_id
  region       = "us-central1"
  network      = "${module.example_network.network.network.self_link}"

  nats = [
    {
      name = "example-nat"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

      subnetworks = [
        {
          name = "${module.example_network.subnets["us-central1/example-bastion-subnet"].self_link}"
          source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]

          secondary_ip_range_names = []
        },
      ]
    },
  ]
}
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



module "one_billion_ms_example_dataset" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 4.2.0"

  dataset_id = "1billion_ms_example_dataset"
  project_id = var.project_id
  location   = "us-east1"
  default_table_expiration_ms = 1e+09


  access = [
  {
    role          = "roles/bigquery.dataOwner"
    special_group = "projectOwners"
  },
  {
    group_by_email = "example-readers@example.com"
    role           = "roles/bigquery.dataViewer"
  },
]

}

module "example_mysql_instance" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/safer_mysql"
  version = "~> 3.2.0"

  name              = "example-mysql-instance"
  project_id        = var.project_id
  region            = "us-central1"
  zone              = "a"
  availability_type = "REGIONAL"
  database_version  = "MYSQL_5_7"
  vpc_network       = "projects/example-prod-networks/global/networks/example-network"
  
  
}
module "project_iam_members" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "~> 6.1.0"

  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    "roles/cloudsql.client" = [
      "serviceAccount:${var.bastion_service_account}",
    ],
  }
}

module "example_prod_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 1.4"

  name       = "example-prod-bucket"
  project_id = var.project_id
  location   = "us-central1"
  iam_members = [
    {
      role   = "roles/storage.objectViewer"
      member = "group:example-readers@example.com"
    },
  ]
}


module "example_healthcare_dataset" {
  source  = "terraform-google-modules/healthcare/google"
  version = "~> 1.0.0"

  name     = "example-healthcare-dataset"
  project  = var.project_id
  location = "us-central1"

  iam_members = [
  {
    member = "group:example-healthcare-dataset-viewers@example.com"
    role   = "roles/healthcare.datasetViewer"
  },
]


  dicom_stores = [
    {
      name = "example-dicom-store"
      
    }
  ]
  fhir_stores = [
    {
      name    = "example-fhir-store"
      version = "R4"

      iam_members = [
  {
    member = "group:example-fhir-viewers@example.com"
    role   = "roles/healthcare.fhirStoreViewer"
  },
]
}
  ]
  hl7_v2_stores = [
    {
      name = "example-hl7-store"
      
    }
  ]
}
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


module "project_iam_members" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  version  = "~> 6.1.0"

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

resource "google_firebase_project" "firebase" {
  provider = google-beta
  project  = var.project_id
}

resource "google_firestore_index" "index" {
  project    = var.project_id
  collection = "example-collection"
  fields {
    field_path = "__name__"
    order      = "ASCENDING"
  }
  fields {
    field_path = "example-field"
    order      = "ASCENDING"
  }
  fields {
    field_path = "createdTimestamp"
    order      = "ASCENDING"
  }
}

