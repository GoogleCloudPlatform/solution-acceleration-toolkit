# Copyright 2021 Google LLC
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
  title                = "Recipe for resources within projects"
  properties = {
    state_bucket = {
      description = "Bucket to store remote state."
      type        = "string"
    }
    state_path_prefix = {
      description = "Path within bucket to store state. Defaults to the template's output_path."
      type        = "string"
    }
    terraform_addons = {
      description = <<EOF
        Additional Terraform configuration for the project deployment.
        Can be used to support arbitrary resources not supported in the following list.
        For schema see ./deployment.hcl.
      EOF
      type                 = "object"
    }
    bastion_hosts = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-bastion-host)"
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
            description = <<EOF
              Name of network project.
              If unset, the current project will be used.
            EOF
            type        = "string"
            pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
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
          labels = {
            description = "Labels to set on the host."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
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
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-bigquery)"
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
              Override for Terraform resource name.
              If unset, defaults to normalized dataset_id.
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
          labels = {
            description = "Labels to set on the dataset."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
          }
          access = {
            description = <<EOF
              Access for this bigquery dataset.
              Each object should contain exactly one of group_by_email, user_by_email, special_group.
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
    binary_authorization = {
      description          = "A policy for container image binary authorization."
      type                 = "object"
      additionalProperties = false
      properties = {
        admission_whitelist_patterns = {
          description = "A whitelist of image patterns to exclude from admission rules."
          type        = "array"
          items = {
            type                 = "object"
            additionalProperties = false
            properties = {
              name_pattern = {
                description = <<EOF
                  An image name pattern to whitelist, in the form registry/path/to/image.
                  This supports a trailing * as a wildcard, but this is allowed
                  only in text after the registry/ part."
                EOF
                type        = "string"
              }
            }
          }
        }
      }
    }
    cloud_sql_instances = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-sql-db/tree/master/modules/safer_mysql)"
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
              Override for Terraform resource name.
              If unset, defaults to normalized name.
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
            description = <<EOF
              Name of network project.
              If unset, the current project will be used.
            EOF
            type        = "string"
            pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
          }
          network = {
            description = "Name of the network."
            type        = "string"
          }
          tier = {
            description = <<EOF
              The
              [tier](https://cloud.google.com/sql/docs/mysql/instance-settings#machine-type-2ndgen)
              for the master instance.
            EOF
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
          deletion_protection = {
            description = <<EOF
              Used to block Terraform from deleting a SQL Instance. Defaults to true.
            EOF
            type        = "boolean"
          }
          labels = {
            description = "Labels to set on the instance."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
          }
        }
      }
    }
    compute_instance_templates = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/instance_template)"
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "name_prefix",
          "subnet",
          "service_account",
        ]
        properties = {
          name_prefix = {
            description = "Name prefix of the instance template."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name.
              If unset, defaults to normalized name_prefix.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          network_project_id = {
            description = <<EOF
              Name of network project.
              If unset, the current project will be used.
            EOF
            type        = "string"
            pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
          }
          subnet = {
            description = "Name of the the instance template's subnet."
            type        = "string"
          }
          service_account = {
            description = "Email of service account to attach to this instance template."
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
          disk_type = {
            description = "Type of disk to use for the instance template."
            type        = "string"
          }
          disk_size_gb = {
            description = "Disk space to set for the instance template."
            type        = "integer"
          }
          preemptible = {
            description = "Whether the instance template can be preempted. Defaults to false."
            type        = "boolean"
          }
          tags = {
            description = <<EOF
              [Network tags](https://cloud.google.com/vpc/docs/add-remove-network-tags)
              for the instance template."
            EOF
            type        = "array"
            items = {
              type = "string"
            }
          }
          enable_shielded_vm = {
            description = "Whether to enable shielded VM. Defaults to true."
            type        = "boolean"
          }
          startup_script = {
            description = "Script to run on startup. Can be multi-line."
            type        = "string"
          }
          labels = {
            description = "Labels to set on the instance template."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
          }
          metadata = {
            description = "Metadata to set on the instance template."
            type        = "object"
          }
          instances = {
            description = "[Module](https://github.com/terraform-google-modules/terraform-google-vm/tree/master/modules/compute_instance)"
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of instance."
                  type        = "string"
                }
                resource_name = {
                  description = <<EOF
                    Override for Terraform resource name.
                    If unset, defaults to normalized name.
                    Normalization will make all characters alphanumeric with underscores.
                  EOF
                  type        = "string"
                }
                access_configs = {
                  description = <<EOF
                    Access configurations, i.e. IPs via which this instance can
                    be accessed via the Internet. Omit to ensure that the
                    instance is not accessible from the Internet.
                  EOF
                  type        = "array"
                  items = {
                    type        = "object"
                    additionalProperties = false
                    required = [
                      "nat_ip"
                    ]
                    properties = {
                      nat_ip = {
                        type = "string"
                        description = "The IP address that will be 1:1 mapped to the instance's network ip."
                      }
                      network_tier = {
                        description = "The networking tier used for configuring this instance."
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
    compute_networks = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-network)"
      type        = "array"
      items = {
        additionalProperties = false
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
              Override for Terraform resource name.
              If unset, defaults to normalized name.
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
          cloud_sql_private_service_access = {
            description = "Whether to enable Cloud SQL private service access. Defaults to false."
            type        = "object"
            additionalProperties = false
          }
        }
      }
    }
    compute_routers = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-cloud-router)"
      type        = "array"
      items = {
        additionalProperties = false
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
              Override for Terraform resource name.
              If unset, defaults to normalized name.
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
                  description = <<EOF
                    Subnet NAT configurations.
                    Only applicable if 'source_subnetwork_ip_ranges_to_nat' is 'LIST_OF_SUBNETWORKS'.
                  EOF
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
                        description = <<EOF
                          List of the secondary ranges of the subnetwork that are allowed to use NAT.
                          Only applicable if one of the values in 'source_ip_ranges_to_nat' is 'LIST_OF_SECONDARY_IP_RANGES'.
                        EOF
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
    dns_zones = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-cloud-dns)"
      type        = "array"
      items = {
        type = "object"
        additionalProperties = false
        required = [
          "name",
          "domain",
          "type",
          "record_sets",
        ]
        properties = {
          name = {
            description = "Name of DNS zone."
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name.
              If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          domain = {
            description = "Domain of DNS zone. Must end with period."
            type        = "string"
            pattern     = "^.+\\.$"
          }
          type = {
            description = "Type of DNS zone."
            type        = "string"
            enum = [
              "public",
              "private",
              "forwarding",
              "peering",
            ]
          }
          record_sets = {
            description = "Records managed by the DNS zone."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              properties = {
                name = {
                  description = "Name of record set."
                  type        = "string"
                }
                type = {
                  description = "Type of record set."
                  type        = "string"
                }
                ttl = {
                  description = "Time to live of this record set, in seconds."
                  type        = "integer"
                }
                records = {
                  description = "Data of the record set."
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
    gke_clusters = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant)"
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
              Override for Terraform resource name.
              If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          gke_region = {
            description = "Region to create GKE cluster in. Can be defined in global data block."
            type        = "string"
          }
          network_project_id = {
            description = <<EOF
              Name of network project.
              If unset, the current project will be used.
            EOF
            type        = "string"
            pattern     = "^[a-z][a-z0-9\\-]{4,28}[a-z0-9]$"
          }
          network = {
            description = "Name of the GKE cluster's network."
            type        = "string"
          }
          subnet = {
            description = "Name of the GKE cluster's subnet."
            type        = "string"
          }
          labels = {
            description = "Labels to set on the cluster."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
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
          node_pools = {
            description = <<EOF
              List of maps containing node pools.
              For supported fields, see the
              [module example](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/examples/node_pool_update_variant).
            EOF
            type = "array"
            items = {
              type = "object"
            }
          }
          service_account = {
            description = <<EOF
              Use the given service account for nodes rather than creating a
              new dedicated service account.
            EOF
            type        = "string"
          }
          istio = {
            description = <<EOF
              Whether or not to enable Istio addon.
            EOF
            type        = "boolean"
          }
        }
      }
    }
    healthcare_datasets = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-healthcare)"
      type        = "array"
      items = {
        additionalProperties = false
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
          consent_stores = {
            description = "Consent stores to create."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of consent store."
                  type        = "string"
                }
                labels = {
                  description = "Labels to set on the consent store. See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_consent_store#labels>."
                  type        = "object"
                  patternProperties = {
                    ".+" = { type = "string" }
                  }
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
                enable_consent_create_on_update = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_consent_store#enable_consent_create_on_update>."
                  type = "boolean"
                }
                default_consent_ttl = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_consent_store#default_consent_ttl>."
                  type = "string"
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
                labels = {
                  description = "Labels to set on the DICOM store."
                  type        = "object"
                  patternProperties = {
                    ".+" = { type = "string" }
                  }
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
                notification_config = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_dicom_store#notification_config>."
                  type        = "object"
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
                enable_update_create = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#enable_update_create>."
                  type        = "boolean"
                }
                disable_referential_integrity = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#disable_referential_integrity>."
                  type        = "boolean"
                }
                disable_resource_versioning = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#disable_resource_versioning>."
                  type        = "boolean"
                }
                enable_history_import = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#enable_history_import>."
                  type        = "boolean"
                }
                labels = {
                  description = "Labels to set on the FHIR store."
                  type        = "object"
                  patternProperties = {
                    ".+" = { type = "string" }
                  }
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
                notification_config = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#notification_config>."
                  type        = "object"
                }
                stream_configs = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_fhir_store#stream_configs>."
                  type        = "array"
                  items = {
                    type = "object"
                    additionalProperties = false
                    required = [
                      "bigquery_destination",
                    ]
                    properties = {
                      resource_types = {
                        type        = "array"
                        items = {
                          type = "string"
                        }
                      }
                      bigquery_destination = {
                        type        = "object"
                        additionalProperties = false
                        required = [
                          "dataset_uri",
                          "schema_config",
                        ]
                        properties = {
                          dataset_uri = {
                            type = "string"
                          }
                          schema_config = {
                            type = "object"
                            additionalProperties = false
                            required = [
                              "recursive_structure_depth",
                            ]
                            properties = {
                              schema_type = {
                                type = "string"
                              }
                              recursive_structure_depth = {
                                type = "integer"
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
                labels = {
                  description = "Labels to set on the HL7 V2 store."
                  type        = "object"
                  patternProperties = {
                    ".+" = { type = "string" }
                  }
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
                notification_configs = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_hl7_v2_store#notification_configs>."
                  type        = "array"
                  items = {
                    type = "object"
                  }
                }
                parser_config = {
                  description = "See <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/healthcare_hl7_v2_store#parser_config>."
                  type        = "object"
                  additionalProperties = false
                  properties = {
                    allow_null_header = {
                      type = "boolean"
                    }
                    segment_terminator = {
                      type = "string"
                    }
                    schema = {
                      type = "string"
                    }
                    version = {
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
    iam_members = {
      description = "Map of IAM role to list of members to grant access to the role."
      type        = "object"
    }
    pubsub_topics = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-pubsub)"
      type        = "array"
      items = {
        additionalProperties = false
        required = [
          "name",
        ]
        properties = {
          name = {
            description = "Name of the topic."
            type        = "string"
          }
          labels = {
            description = "Labels to set on the topic."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
          }
          pull_subscriptions = {
            description = "Pull subscriptions on the topic."
            type        = "array"
            items = {
              type = "object"
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of subscription."
                  type        = "string"
                }
                ack_deadline_seconds = {
                  description = "Deadline to wait for acknowledgement."
                  type        = "integer"
                }
              }
            }
          }
          push_subscriptions = {
            description = "Push subscriptions on the topic."
            type        = "array"
            items = {
              type = "object"
              additionalProperties = false
              required = [
                "name",
              ]
              properties = {
                name = {
                  description = "Name of subscription."
                  type        = "string"
                }
                push_endpoint = {
                  description = "Name of endpoint to push to."
                  type        = "string"
                }
                ack_deadline_seconds = {
                  description = "Deadline to wait for acknowledgement."
                  type        = "integer"
                }
              }
            }
          }
        }
      }
    }
    secrets = {
      description = "[Module](https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html)"
      type        = "array"
      items = {
        additionalProperties = false
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
              Override for Terraform resource name.
              If unset, defaults to normalized secret_id.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          secret_locations = {
            description = "Locations to replicate secret. Can be defined in global data block."
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
      description = "[Module](https://www.terraform.io/docs/providers/google/r/google_service_account.html)"
      type        = "array"
      items = {
        additionalProperties = false
        required = [
          "account_id",
        ]
        properties = {
          account_id = {
            description = "ID of service account."
            type        = "string"
          }
          display_name = {
            description = "Display name of service account."
            type        = "string"
          }
          description = {
            description = "Description of service account."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name.
              If unset, defaults to normalized account_id.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
        }
      }
    }
    storage_buckets = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-cloud-storage/tree/master/modules/simple_bucket)"
      type        = "array"
      additionalProperties = false
      items = {
        properties = {
          name = {
            description = "Name of storage bucket."
            type        = "string"
          }
          resource_name = {
            description = <<EOF
              Override for Terraform resource name.
              If unset, defaults to normalized name.
              Normalization will make all characters alphanumeric with underscores.
            EOF
            type        = "string"
          }
          storage_location = {
            description = "Location to create the storage bucket. Can be defined in global data block."
            type        = "string"
          }
          labels = {
            description = "Labels to set on the bucket."
            type        = "object"
            patternProperties = {
              ".+" = { type = "string" }
            }
          }
          lifecycle_rules = {
            description = "Lifecycle rules configuration for the bucket."
            type        = "array"
            items = {
              type                 = "object"
              additionalProperties = false
              properties = {
                action = {
                  description          = "The Lifecycle Rule's action configuration."
                  type                 = "object"
                  additionalProperties = false
                  properties = {
                    type = {
                      description = "Type of action. Supported values: Delete and SetStorageClass."
                      type        = "string"
                    }
                    storage_class = {
                      description = <<EOF
                        (Required if action type is SetStorageClass)
                        The target Storage Class of objects affected by this Lifecycle Rule.
                      EOF
                      type        = "string"
                    }
                  }
                }
                condition = {
                  description          = "The Lifecycle Rule's condition configuration."
                  type                 = "object"
                  additionalProperties = false
                  properties = {
                    age = {
                      description = "Minimum age of an object in days."
                      type        = "integer"
                    }
                    created_before = {
                      description = "Creation date of an object in RFC 3339 (e.g. 2017-06-13)."
                      type        = "string"
                    }
                    with_state = {
                      description = "Match to live and/or archived objects."
                      type        = "string"
                      enum = [
                        "LIVE",
                        "ARCHIVED",
                        "ANY",
                      ]
                    }
                    matches_storage_class = {
                      description = "Storage Class of objects."
                      type        = "string"
                      enum = [
                        "STANDARD",
                        "MULTI_REGIONAL",
                        "REGIONAL",
                        "NEARLINE",
                        "COLDLINE",
                        "DURABLE_REDUCED_AVAILABILITY",
                      ]
                    }
                    num_newer_versions = {
                      description = <<EOF
                        Relevant only for versioned objects.
                        The number of newer versions of an object."
                      EOF
                      type        = "integer"
                    }
                  }
                }
              }
            }
          }
          retention_policy = {
            description = <<EOF
              Configuration of the bucket's data retention policy for how long
              objects in the bucket should be retained.
            EOF
            type        = "object"
            properties = {
              is_locked = {
                description = <<EOF
                  If set to true, the bucket will be
                  [locked](https://cloud.google.com/storage/docs/bucket-lock#overview)
                  and permanently restrict edits to the bucket's retention
                  policy. Caution: Locking a bucket is an irreversible action.
                  Defaults to false.
                EOF
                type = "boolean"
              }
              retention_period = {
                description = <<EOF
                  The period of time, in seconds, that objects in the bucket
                  must be retained and cannot be deleted, overwritten, or
                  archived. The value must be less than 2,147,483,647 seconds.
                EOF
                type        = "number"
              }
            }
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
    groups = {
      description = "[Module](https://github.com/terraform-google-modules/terraform-google-group)"
      type        = "array"
      items = {
        type                 = "object"
        additionalProperties = false
        required = [
          "id",
          "customer_id",
        ]
        properties = {
          id = {
            description = "Email address of the group."
            type        = "string"
          }
          customer_id = {
            description = <<EOF
              Customer ID of the organization to create the group in.
              See <https://cloud.google.com/resource-manager/docs/organization-policy/restricting-domains#retrieving_customer_id>
              for how to obtain it.
            EOF
            type        = "string"
          }
          description = {
            description = "Description of the group."
            type        = "string"
          }
          display_name = {
            description = "Display name of the group."
            type        = "string"
          }
          owners = {
            description = "Owners of the group."
            type        = "array"
            items = {
              type = "string"
            }
          }
          # Due to limitations in the underlying module, managers and members
          # are not supported and should be configured in the Google Workspace
          # Admin console.
          # managers = {
          #   description = "Managers of the group."
          #   type        = "array"
          #   items = {
          #     type = "string"
          #   }
          # }
          # members = {
          #   description = "Members of the group."
          #   type        = "array"
          #   items = {
          #     type = "string"
          #   }
          # }
        }
      }
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

{{if has . "binary_authorization"}}
template "binary_authorization" {
  component_path = "../components/resources/binary_authorization"
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

{{if has . "dns_zones"}}
template "dns_zones" {
  component_path = "../components/resources/dns_zones"
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

{{if has . "iam_members"}}
template "iam_members" {
  component_path = "../components/resources/iam_members"
}
{{end}}

{{if has . "secrets"}}
template "secrets" {
  component_path = "../components/resources/secrets"
}
{{end}}

{{if has . "pubsub_topics"}}
template "pubsub_topics" {
  component_path = "../components/resources/pubsub_topics"
}
{{end}}

{{if has . "service_accounts"}}
template "service_accounts" {
  component_path = "../components/resources/service_accounts"
}
{{end}}

{{if has . "storage_buckets"}}
template "storage_buckets" {
  component_path = "../components/resources/storage_buckets"
}
{{end}}

{{if has . "groups"}}
template "groups" {
  component_path = "../components/resources/groups"
}
{{end}}
