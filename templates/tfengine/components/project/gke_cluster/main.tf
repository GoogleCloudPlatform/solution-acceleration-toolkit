module "{{resourceName .NAME}}" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  version = "9.0.0"

  # Required.
  name                   = "{{.NAME}}"
  project_id             = var.project_id
  region                 = var.cluster_region
  regional               = true
  network                = "{{.NETWORK}}"
  subnetwork             = "{{.SUBNET}}"
  ip_range_pods          = "{{.IP_RANGE_PODS_NAME}}"
  ip_range_services      = "{{.IP_RANGE_SERVICES_NAME}}"
  master_ipv4_cidr_block = "{{.MASTER_IPV4_CIDR_BLOCK}}"

  # Optional.
  master_authorized_networks = var.master_authorized_networks
  istio                      = true
  skip_provisioners          = true
  enable_private_endpoint    = false
  release_channel            = "STABLE"
}
