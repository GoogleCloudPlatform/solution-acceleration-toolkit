# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

schema = {
  title = "Recipe for project resources."
  properties = {
    bastion_hosts = {
      description = "https://github.com/terraform-google-modules/terraform-google-bastion-host"
      type        = "array"
      items = {
        type = "object"
        required = [
          "name",
          "network",
          "subnet",
          "members",
        ]
        properties = {
          name = {
            description = "Name of bastion host."
            type        = "string"
          }
          network_project_id = {
            description = "Name of network project. If unset, will use the current project."
            type        = "string"
          }
          network = {
            description = "Name of network to connect to."
            type        = "string"
          }
          subnet = {
            description = "Name of subnet to connect to."
            type        = "string"
          }
          compute_region = {
            description = "Region to create bastion host in. Can be defined in global data block."
            type        = "string"
          }
          compute_zone = {
            description = "Zone to create bastion host in. Can be defined in global data block."
            type        = "string"
          }
          image_project = {
            description = "Project of compute image to use."
            type        = "string"
          }
          image_family = {
            description = "Family of compute image to use."
            type        = "string"
          }
          members = {
            description = "Members who can access the bastion host."
            type        = "array"
            items = {
              type = "string"
            }
          }
          scopes = {
            description = "Scopes to grant. If unset, will grant access to all cloud platform scopes."
            type        = "array"
            items = {
              type = "string"
            }
          }
          startup_script = {
            description = "Script to run on startup. Can be multi-line."
            type        = "string"
          }
        }
      }
    }
    bigquery_datasets = {
      description = "https://github.com/terraform-google-modules/terraform-google-bigquery"
      type        = "array"
      items = {
        type = "object"
        required = [
          "dataset_id",
        ]
        properties = {
          dataset_id = {
            description = "ID of bigquery dataset."
            type        = "string"
          }
          bigquery_location = {
            description = "Location to create the bigquery dataset. Can be defined in global data block."
            type        = "string"
          }
          default_table_expiration_ms = {
            description = "Expiration in milliseconds."
            type        = "integer"
          }
          access = {
            description = <<EOF
              Access for this bigquery dataset.
              Each object should contain exactly one of the following keys:
              - group_by_email: An email address of a Google Group to grant access to.
              - user_by_email:  An email address of a user to grant access to.
              - group_by_email: An email address of a Google Group to grant access to.
              - special_group: A special group to grant access to.
            EOF
            type        = "array"
            items = {
              type = "object"
            }
          }
        }
      }
    }
    cloud_sql_instances = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of the cloud sql instance."
            type        = "string"
          }
          cloud_sql_region = {
            description = "Region to create cloud sql instance in. Can be defined in global data block."
            type        = "string"
          }
          cloud_sql_zone = {
            description = "Zone to reate cloud sql instance in. Can be defined in global data block."
            type        = "string"
          }
          network_project_id = {
            description = "Name of network project. If unset, will use the current project."
            type        = "string"
          }
          network = {
            description = "Name of the network."
            type        = "string"
          }
          user_name = {
            description = "Default user name."
            type        = "string"
          }
          user_password = {
            description = "Default user password."
            type        = "string"
          }
        }
      }
    }
    compute_networks = {
      description = "https://github.com/terraform-google-modules/terraform-google-network"
      type        = "array"
      items = {
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of network."
            type        = "string"
          }
          subnets = {
            description = "Subnetworks within the network."
            type        = "array"
            items = {
              type = "object"
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of subnet."
                  type        = "string"
                }
                ip_range = {
                  description = "IP range of the subnet."
                  type         = "string"
                }
                compute_region = {
                  description = "Region to create subnet in. Can be defined in global data block."
                  type        = "string"
                }
                cloud_sql_private_service_access = {
                  description = "Whether to enable Cloud SQL private service access. Defaults to false."
                  type        = "boolean"
                }
                secondary_ranges = {
                  description = "Secondary ranges of the subnet."
                  type        = "array"
                  items = {
                    type = "object"
                    required = [
                      "name",
                    ]
                    properties = {
                      name = {
                        description = "Name of secondary range."
                        type        = "string"
                      }
                      ip_range = {
                        description = "IP range for the secondary range."
                        type        = "string"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    compute_routers = {
      description = "https://github.com/terraform-google-modules/terraform-google-cloud-router"
      type        = "array"
      items = {
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of router."
            type        = "string"
          }
          compute_region = {
            description = "Region to create subnet in. Can be defined in global data block."
            type        = "string"
          }
          network = {
            description = "Name of network the router belongs to."
            type        = "string"
          }
          nats = {
            description = "NATs to attach to the router."
            type        = "array"
            items = {
              type = "object"
              required = [
                "name",
              ]
              name = {
                description = "Name of NAT."
                type        = "string"
              }
              source_subnetwork_ip_ranges_to_nat = {
                description = "How NAT should be configured per Subnetwork."
                type        = "string"
              }
              subnetworks = {
                description = "Subnet NAT configurations. Only applicable if 'source_subnetwork_ip_ranges_to_nat' is 'LIST_OF_SUBNETWORKS'."
                type        = "array"
                item = {
                  type = "object"
                  required = [
                    "name",
                    "source_ip_ranges_to_nat",
                  ]
                  properties = {
                    name = {
                      description = "Name of subnet."
                      type        = "string"
                    }
                    source_ip_ranges_to_nat = {
                      description = "List of options for which source IPs in the subnetwork should have NAT enabled."
                      type        = "array"
                      items = {
                        type = "string"
                      }
                    }
                    secondary_ip_range_names  = {
                      description = "List of the secondary ranges of the subnetwork that are allowed to use NAT. Only applicable if one of the values in 'source_ip_ranges_to_nat' is 'LIST_OF_SECONDARY_IP_RANGES'."
                      type        = "array"
                      items = {
                        type = "string"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    gke_clusters = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [

        ]
        properties = {

        }
      }
    }
    healthcare_datasets = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [

        ]
        properties = {

        }
      }
    }
    iam_members = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "object"
    }
    secrets = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [

        ]
        properties = {

        }
      }
    }
    service_accounts = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [

        ]
        properties = {

        }
      }
    }
    storage_buckets = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [

        ]
        properties = {

        }
      }
    }

  }
}

template "deployment" {
  recipe_path = "../deployment/project.hcl"
}

{{if has . "bastion_hosts"}}
template "bastion_hosts" {
  component_path = "../../components/project/bastion_hosts"
}
{{end}}

{{if has . "bigquery_datasets"}}
template "bigquery_datasets" {
  component_path = "../../components/project/bigquery_datasets"
}
{{end}}

{{if has . "cloud_sql_instances"}}
template "cloud_sql_instances" {
  component_path = "../../components/project/cloud_sql_instances"
}
{{end}}

{{if has . "compute_networks"}}
template "compute_networks" {
  component_path = "../../components/project/compute_networks"
}
{{end}}

{{if has . "compute_routers"}}
template "compute_routers" {
  component_path = "../../components/project/compute_routers"
}
{{end}}

{{if has . "gke_clusters"}}
template "gke_clusters" {
  component_path = "../../components/project/gke_clusters"
}
{{end}}

{{if has . "healthcare_datasets"}}
template "healthcare_datasets" {
  component_path = "../../components/project/healthcare_datasets"
}
{{end}}

{{if has . "iam_members"}}
template "iam_members" {
  component_path = "../../components/project/iam_members"
}
{{end}}

{{if has . "secrets"}}
template "secrets" {
  component_path = "../../components/org/secrets"
}
{{end}}

{{if has . "service_accounts"}}
template "service_accounts" {
  component_path = "../../components/project/service_accounts"
}

{{if has . "storage_buckets"}}
template "storage_buckets" {
  component_path = "../../components/project/storage_buckets"
}
{{end}}
{{end}}
