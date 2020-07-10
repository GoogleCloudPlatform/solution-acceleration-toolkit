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
  title                = "Recipe for resources within projects."
  additionalProperties = false
  properties = {
    terraform_addons = {
      description = <<EOF
        Additional Terraform configuration for the project deployment.
        Can be used to support arbitrary resources not supported in the following list.
        For schema see ./deployment.hcl.
      EOF
      type                 = "object"
    }
    bastion_hosts = {
      description = "https://github.com/terraform-google-modules/terraform-google-bastion-host"
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
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
            description = "Name of the bastion host's network."
            type        = "string"
          }
          subnet = {
            description = "Name of the bastion host's subnet."
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
        type                 = "object"
        additionalProperties = false
        required = [
          "dataset_id",
        ]
        properties = {
          dataset_id = {
            description = "ID of bigquery dataset."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized dataset_id.
              Normalization will make all characters alphanumeric with underscores.
            EOF
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
              - group_by_email
              - user_by_email
              - special_group
            EOF
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              properties = {
                role = {
                  description = "Role to grant."
                  type        = "string"
                }
                group_by_email = {
                  description = "An email address of a Google Group to grant access to."
                  type        = "string"
                }
                user_by_email = {
                  description = "An email address of a user to grant access to."
                  type        = "string"
                }
                special_group = {
                  description = "A special group to grant access to."
                  type        = "string"
                }
              }
            }
          }
        }
      }
    }
    cloud_sql_instances = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of the cloud sql instance."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          type = {
            description = "Type of the cloud sql instance. Currently only supports 'mysql'."
            type        = "string"
            pattern = "^mysql$"
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
    compute_instance_templates = {
      description = "https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template"
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
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          subnets = {
            description = "Subnetworks within the network."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
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
                    type                 = "object"
                    additionalProperties = false
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
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
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
              type                 = "object"
              additionalProperties = false
              required = [
                "name",
              ]
              properties = {
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
                  items = {
                    type                 = "object"
                    additionalProperties = false
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
    }
    gke_clusters = {
      description = "https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant"
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of GKE cluster."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          gke_region = {
            description = "Region to create GKE cluster in. Can be defined in global data block."
            type        = "string"
          }
          network_project_id = {
            description = "Name of network project. If unset, will use the current project."
            type        = "string"
          }
          network = {
            description = "Name of the GKE cluster's network."
            type        = "string"
          }
          subnet = {
            description = "Name of the GKE cluster's subnet."
            type        = "string"
          }
          ip_range_pods_name = {
            description = "Name of the secondary subnet ip range to use for pods."
            type        = "string"
          }
          ip_range_services_name = {
            description = "Name of the secondary subnet range to use for services."
            type        = "string"
          }
          master_ipv4_cidr_block = {
            description = "IP range in CIDR notation to use for the hosted master network."
            type        = "string"
          }
          master_authorized_networks = {
            description = <<EOF
              List of master authorized networks. If none are provided, disallow external
              access (except the cluster node IPs, which GKE automatically allows).
            EOF
            type  = "array"
            items = {
              type = "object"
              additionalProperties = false
              required = [
                "cidr_block",
                "display_name",
              ]
              properties = {
                cidr_block = {
                  description = "CIDR block of the master authorized network."
                  type        = "string"
                }
                display_name = {
                  description = "Display name of the master authorized network."
                  type        = "string"
                }
              }
            }
          }
        }
      }
    }
    healthcare_datasets = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of healthcare dataset."
            type        = "string"
          }
          healthcare_region = {
            description = "Region to create healthcare dataset in. Can be defined in global data block."
            type        = "string"
          }
          iam_members = {
            description = "IAM member to grant access for."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "role",
                "member",
              ]
              properties = {
                role = {
                  description = "IAM role to grant."
                  type        = "string"
                }
                member = {
                  description = "Member to grant acess to role."
                  type        = "string"
                }
              }
            }
          }
          dicom_stores = {
            description = "Dicom stores to create."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of dicom store."
                  type        = "string"
                }
                iam_members = {
                  description = "IAM member to grant access for."
                  type        = "array"
                  items = {
                    type                 = "object"
                    additionalProperties = false
                    required = [
                      "role",
                      "member",
                    ]
                    properties = {
                      role = {
                        description = "IAM role to grant."
                        type        = "string"
                      }
                      member = {
                        description = "Member to grant acess to role."
                        type        = "string"
                      }
                    }
                  }
                }
              }
            }
          }
          fhir_stores = {
            description = "FHIR stores to create."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "name",
                "version",
              ]
              properties = {
                name = {
                  description = "Name of FHIR store."
                  type        = "string"
                }
                version = {
                  description = "Version of FHIR store."
                  type        = "string"
                }
                iam_members = {
                  description = "IAM member to grant access for."
                  type        = "array"
                  items = {
                    type                 = "object"
                    additionalProperties = false
                    required = [
                      "role",
                      "member",
                    ]
                    properties = {
                      role = {
                        description = "IAM role to grant."
                        type        = "string"
                      }
                      member = {
                        description = "Member to grant acess to role."
                        type        = "string"
                      }
                    }
                  }
                }
              }
            }
          }
          hl7_v2_stores = {
            description = "HL7 V2 stores to create."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of Hl7 V2 store."
                  type        = "string"
                }
                iam_members = {
                  description = "IAM member to grant access for."
                  type        = "array"
                  items = {
                    type                 = "object"
                    additionalProperties = false
                    required = [
                      "role",
                      "member",
                    ]
                    properties = {
                      role = {
                        description = "IAM role to grant."
                        type        = "string"
                      }
                      member = {
                        description = "Member to grant acess to role."
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
    iam_members = {
      description = "Map of IAM role to list of members to grant access to the role."
      type        = "object"
    }
    secrets = {
      description = "https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html"
      type        = "array"
      items = {
        required = [
          "secret_id",
        ]
        properties = {
          secret_id = {
            description = "ID of secret."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized secret_id.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          locations = {
            description = "Locations to replicate secret. If unset, will automatically replicate."
            type        = "array"
            items = {
              type = "string"
            }
          }
          secret_data = {
            description = "Data of the secret. If unset, should be manually set in the GCP console."
            type        = "string"
          }
        }
      }
    }
    service_accounts = {
      description = "https://www.terraform.io/docs/providers/google/r/google_service_account.html"
      type        = "array"
      items = {
        required = [
          "account_id",
        ]
        properties = {
          account_id = {
            description = "ID of service account."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized account_id.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
        }
      }
    }
    storage_buckets = {
      description = "https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql"
      type        = "array"
      items = {
        required = [
          "name"
        ]
        properties = {
          name = {
            description = "Name of storage bucket."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name. If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          storage_location = {
            description = "Location to create the storage bucket. Can be defined in global data block."
            type        = "string"
          }
          iam_members = {
            description = "IAM member to grant access for."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "role",
                "member",
              ]
              properties = {
                role = {
                  description = "IAM role to grant."
                  type        = "string"
                }
                member = {
                  description = "Member to grant acess to role."
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

template "deployment" {
  recipe_path = "./deployment.hcl"
  data = {
    enable_terragrunt = true
    terraform_addons = {
      vars = [{
        name             = "project_id"
        type             = "string"
        terragrunt_input = "$${dependency.project.outputs.project_id}"
      }]
      deps = [{
        name = "project"
        path = "../project"
        mock_outputs = {
          project_id = "mock-project"
        }
      }]
    }
  }
}

{{if has . "bastion_hosts"}}
template "bastion_hosts" {
  component_path = "../components/resources/bastion_hosts"
}
{{end}}

{{if has . "bigquery_datasets"}}
template "bigquery_datasets" {
  component_path = "../components/resources/bigquery_datasets"
}
{{end}}

{{if has . "cloud_sql_instances"}}
template "cloud_sql_instances" {
  component_path = "../components/resources/cloud_sql_instances"
}
{{end}}

{{if has . "compute_instance_templates"}}
template "compute_instance_templates" {
  component_path = "../components/resources/compute_instance_templates"
}
{{end}}

{{if has . "compute_networks"}}
template "compute_networks" {
  component_path = "../components/resources/compute_networks"
}
{{end}}

{{if has . "compute_routers"}}
template "compute_routers" {
  component_path = "../components/resources/compute_routers"
}
{{end}}

{{if has . "iam_members"}}
template "iam_members" {
  component_path = "../components/resources/iam_members"
}
{{end}}

{{if has . "storage_buckets"}}
template "storage_buckets" {
  component_path = "../components/resources/storage_buckets"
}
{{end}}

{{if has . "gke_clusters"}}
template "gke_clusters" {
  component_path = "../components/resources/gke_clusters"
}
{{end}}

{{if has . "healthcare_datasets"}}
template "healthcare_datasets" {
  component_path = "../components/resources/healthcare_datasets"
}
{{end}}

{{if has . "secrets"}}
template "secrets" {
  component_path = "../components/resources/secrets"
}
{{end}}

{{if has . "service_accounts"}}
template "service_accounts" {
  component_path = "../components/resources/service_accounts"
}
{{end}}
