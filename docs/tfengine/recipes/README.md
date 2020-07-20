# README

## Top-level Schemas

-   [Devops Recipe](./devops.md) – `-`
-   [Org Audit Recipe](./audit.md) – `-`
-   [Org Monitor Recipe](./monitor.md) – `-`
-   [Recipe for creating GCP folders.](./folder.md) – `-`
-   [Recipe for creating GCP projects.](./project.md) – `-`
-   [Recipe for resources within projects.](./resources.md) – `-`
-   [Terraform Deployment Recipe.](./deployment.md "This recipe should be used to setup a new Terraform deployment directory") – `-`

## Other Schemas

### Objects

-   [Untitled object in Devops Recipe](./devops-properties-project.md "Config for the project to host devops related resources such as state bucket and CICD") – `undefined#/properties/project`
-   [Untitled object in Devops Recipe](./devops-properties-cicd.md "Config for CICD") – `undefined#/properties/cicd`
-   [Untitled object in Devops Recipe](./devops-properties-cicd-properties-apply_trigger.md "        Config block for the postsubmit apply/deployyemt Cloud Build trigger") – `undefined#/properties/cicd/properties/apply_trigger`
-   [Untitled object in Devops Recipe](./devops-properties-cicd-properties-cloud_source_repository.md "Config for Google Cloud Source Repository Cloud Build triggers") – `undefined#/properties/cicd/properties/cloud_source_repository`
-   [Untitled object in Devops Recipe](./devops-properties-cicd-properties-github.md "Config for GitHub Cloud Build triggers") – `undefined#/properties/cicd/properties/github`
-   [Untitled object in Devops Recipe](./devops-properties-cicd-properties-plan_trigger.md "        Config block for the presubmit plan Cloud Build trigger") – `undefined#/properties/cicd/properties/plan_trigger`
-   [Untitled object in Devops Recipe](./devops-properties-cicd-properties-validate_trigger.md "        Config block for the presubmit validation Cloud Build trigger") – `undefined#/properties/cicd/properties/validate_trigger`
-   [Untitled object in Org Audit Recipe](./audit-properties-logs_bigquery_dataset.md "Bigquery Dataset to host audit logs for 1 year") – `undefined#/properties/logs_bigquery_dataset`
-   [Untitled object in Org Audit Recipe](./audit-properties-project.md "Config of project to host auditing resources") – `undefined#/properties/project`
-   [Untitled object in Org Audit Recipe](./audit-properties-logs_storage_bucket.md "GCS bucket to host audit logs for 7 years") – `undefined#/properties/logs_storage_bucket`
-   [Untitled object in Org Monitor Recipe](./monitor-properties-forseti.md "Config for the Forseti instance") – `undefined#/properties/forseti`
-   [Untitled object in Org Monitor Recipe](./monitor-properties-project.md "Config of project to host monitoring resources") – `undefined#/properties/project`
-   [Untitled object in Recipe for creating GCP projects.](./project-properties-deployments.md "    Map of deployment name to resources config") – `undefined#/properties/deployments`
-   [Untitled object in Recipe for creating GCP projects.](./project-properties-project.md "Config for the project") – `undefined#/properties/project`
-   [Untitled object in Recipe for creating GCP projects.](./project-properties-project-properties-shared_vpc_attachment.md "If set, treats this project as a shared VPC service project") – `undefined#/properties/project/properties/shared_vpc_attachment`
-   [Untitled object in Recipe for creating GCP projects.](./project-properties-project-properties-shared_vpc_attachment-properties-subnets-items.md) – `undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-terraform_addons.md "    Additional Terraform configuration for the project deployment") – `undefined#/properties/terraform_addons`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-condition.md) – `undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/condition`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-storage_buckets-items-properties-lifecycle_rules-items-properties-action.md) – `undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items/properties/action`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-storage_buckets-items-properties-lifecycle_rules-items.md) – `undefined#/properties/storage_buckets/items/properties/lifecycle_rules/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-storage_buckets-items-properties-iam_members-items.md) – `undefined#/properties/storage_buckets/items/properties/iam_members/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-pubsub_topics-items-properties-push_subscriptions-items.md) – `undefined#/properties/pubsub_topics/items/properties/push_subscriptions/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-bastion_hosts-items.md) – `undefined#/properties/bastion_hosts/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-bigquery_datasets-items.md) – `undefined#/properties/bigquery_datasets/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-bigquery_datasets-items-properties-access-items.md) – `undefined#/properties/bigquery_datasets/items/properties/access/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-binary_authorization.md "A policy for container image binary authorization") – `undefined#/properties/binary_authorization`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-pubsub_topics-items-properties-pull_subscriptions-items.md) – `undefined#/properties/pubsub_topics/items/properties/pull_subscriptions/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-cloud_sql_instances-items.md) – `undefined#/properties/cloud_sql_instances/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-compute_instance_templates-items.md) – `undefined#/properties/compute_instance_templates/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-compute_instance_templates-items-properties-instances-items.md) – `undefined#/properties/compute_instance_templates/items/properties/instances/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-compute_networks-items-properties-subnets-items.md) – `undefined#/properties/compute_networks/items/properties/subnets/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges-items.md) – `undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-compute_routers-items-properties-nats-items.md) – `undefined#/properties/compute_routers/items/properties/nats/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items.md) – `undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-dns_zones-items.md) – `undefined#/properties/dns_zones/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-dns_zones-items-properties-record_sets-items.md) – `undefined#/properties/dns_zones/items/properties/record_sets/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-gke_clusters-items.md) – `undefined#/properties/gke_clusters/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-gke_clusters-items-properties-master_authorized_networks-items.md) – `undefined#/properties/gke_clusters/items/properties/master_authorized_networks/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-dicom_stores-items.md) – `undefined#/properties/healthcare_datasets/items/properties/dicom_stores/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-dicom_stores-items-properties-iam_members-items.md) – `undefined#/properties/healthcare_datasets/items/properties/dicom_stores/items/properties/iam_members/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-fhir_stores-items.md) – `undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members-items.md) – `undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-hl7_v2_stores-items.md) – `undefined#/properties/healthcare_datasets/items/properties/hl7_v2_stores/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-hl7_v2_stores-items-properties-iam_members-items.md) – `undefined#/properties/healthcare_datasets/items/properties/hl7_v2_stores/items/properties/iam_members/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-iam_members-items.md) – `undefined#/properties/healthcare_datasets/items/properties/iam_members/items`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-iam_members.md "Map of IAM role to list of members to grant access to the role") – `undefined#/properties/iam_members`
-   [Untitled object in Recipe for resources within projects.](./resources-properties-binary_authorization-properties-admission_whitelist_patterns-items.md) – `undefined#/properties/binary_authorization/properties/admission_whitelist_patterns/items`
-   [Untitled object in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-vars-items.md) – `undefined#/properties/terraform_addons/properties/vars/items`
-   [Untitled object in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-outputs-items.md) – `undefined#/properties/terraform_addons/properties/outputs/items`
-   [Untitled object in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-inputs.md "Additional inputs to be set in terraform") – `undefined#/properties/terraform_addons/properties/inputs`
-   [Untitled object in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-deps-items-properties-mock_outputs.md "Mock outputs for the deployment to add") – `undefined#/properties/terraform_addons/properties/deps/items/properties/mock_outputs`
-   [Untitled object in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-deps-items.md) – `undefined#/properties/terraform_addons/properties/deps/items`
-   [Untitled object in Terraform Deployment Recipe.](./deployment-properties-terraform_addons.md "Extra addons to set in the deployment") – `undefined#/properties/terraform_addons`

### Arrays

-   [Untitled array in Devops Recipe](./devops-properties-cicd-properties-build_viewers.md "IAM members to grant cloudbuild") – `undefined#/properties/cicd/properties/build_viewers`
-   [Untitled array in Devops Recipe](./devops-properties-cicd-properties-managed_services.md "        APIs to enable in the devops project so the Cloud Build service account can manage") – `undefined#/properties/cicd/properties/managed_services`
-   [Untitled array in Devops Recipe](./devops-properties-project-properties-owners.md "        List of members to transfer ownership of the project to") – `undefined#/properties/project/properties/owners`
-   [Untitled array in Recipe for creating GCP projects.](./project-properties-project-properties-apis.md "APIs to enable in the project") – `undefined#/properties/project/properties/apis`
-   [Untitled array in Recipe for creating GCP projects.](./project-properties-project-properties-shared_vpc_attachment-properties-subnets.md "Subnets within the host project to grant this project access to") – `undefined#/properties/project/properties/shared_vpc_attachment/properties/subnets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-secondary_ip_range_names.md "List of the secondary ranges of the subnetwork that are allowed to use NAT") – `undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/secondary_ip_range_names`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-storage_buckets-items-properties-iam_members.md "IAM member to grant access for") – `undefined#/properties/storage_buckets/items/properties/iam_members`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-storage_buckets-items-properties-lifecycle_rules.md "Lifecycle rules configuration for the bucket") – `undefined#/properties/storage_buckets/items/properties/lifecycle_rules`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-bastion_hosts.md "https&#x3A;//github") – `undefined#/properties/bastion_hosts`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-bastion_hosts-items-properties-members.md "Members who can access the bastion host") – `undefined#/properties/bastion_hosts/items/properties/members`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-bastion_hosts-items-properties-scopes.md "Scopes to grant") – `undefined#/properties/bastion_hosts/items/properties/scopes`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-bigquery_datasets.md "https&#x3A;//github") – `undefined#/properties/bigquery_datasets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-bigquery_datasets-items-properties-access.md "          Access for this bigquery dataset") – `undefined#/properties/bigquery_datasets/items/properties/access`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-binary_authorization-properties-admission_whitelist_patterns.md "A whitelist of image patterns to exclude from admission rules") – `undefined#/properties/binary_authorization/properties/admission_whitelist_patterns`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-cloud_sql_instances.md "https&#x3A;//github") – `undefined#/properties/cloud_sql_instances`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_instance_templates.md "https&#x3A;//github") – `undefined#/properties/compute_instance_templates`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_instance_templates-items-properties-instances.md "https&#x3A;//github") – `undefined#/properties/compute_instance_templates/items/properties/instances`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_networks.md "https&#x3A;//github") – `undefined#/properties/compute_networks`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_networks-items-properties-subnets.md "Subnetworks within the network") – `undefined#/properties/compute_networks/items/properties/subnets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_networks-items-properties-subnets-items-properties-secondary_ranges.md "Secondary ranges of the subnet") – `undefined#/properties/compute_networks/items/properties/subnets/items/properties/secondary_ranges`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_routers.md "https&#x3A;//github") – `undefined#/properties/compute_routers`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_routers-items-properties-nats.md "NATs to attach to the router") – `undefined#/properties/compute_routers/items/properties/nats`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks.md "Subnet NAT configurations") – `undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-storage_buckets.md "https&#x3A;//github") – `undefined#/properties/storage_buckets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-compute_routers-items-properties-nats-items-properties-subnetworks-items-properties-source_ip_ranges_to_nat.md "List of options for which source IPs in the subnetwork should have NAT enabled") – `undefined#/properties/compute_routers/items/properties/nats/items/properties/subnetworks/items/properties/source_ip_ranges_to_nat`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-dns_zones.md "https&#x3A;//github") – `undefined#/properties/dns_zones`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-dns_zones-items-properties-record_sets.md "Records managed by the DNS zone") – `undefined#/properties/dns_zones/items/properties/record_sets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-dns_zones-items-properties-record_sets-items-properties-records.md "Data of the record set") – `undefined#/properties/dns_zones/items/properties/record_sets/items/properties/records`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-gke_clusters.md "https&#x3A;//github") – `undefined#/properties/gke_clusters`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-gke_clusters-items-properties-master_authorized_networks.md "          List of master authorized networks") – `undefined#/properties/gke_clusters/items/properties/master_authorized_networks`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets.md "https&#x3A;//github") – `undefined#/properties/healthcare_datasets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-dicom_stores.md "Dicom stores to create") – `undefined#/properties/healthcare_datasets/items/properties/dicom_stores`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-dicom_stores-items-properties-iam_members.md "IAM member to grant access for") – `undefined#/properties/healthcare_datasets/items/properties/dicom_stores/items/properties/iam_members`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-fhir_stores.md "FHIR stores to create") – `undefined#/properties/healthcare_datasets/items/properties/fhir_stores`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-fhir_stores-items-properties-iam_members.md "IAM member to grant access for") – `undefined#/properties/healthcare_datasets/items/properties/fhir_stores/items/properties/iam_members`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-hl7_v2_stores.md "HL7 V2 stores to create") – `undefined#/properties/healthcare_datasets/items/properties/hl7_v2_stores`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-hl7_v2_stores-items-properties-iam_members.md "IAM member to grant access for") – `undefined#/properties/healthcare_datasets/items/properties/hl7_v2_stores/items/properties/iam_members`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-healthcare_datasets-items-properties-iam_members.md "IAM member to grant access for") – `undefined#/properties/healthcare_datasets/items/properties/iam_members`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-pubsub_topics.md "https&#x3A;//github") – `undefined#/properties/pubsub_topics`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-pubsub_topics-items-properties-pull_subscriptions.md "Pull subscriptions on the topic") – `undefined#/properties/pubsub_topics/items/properties/pull_subscriptions`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-pubsub_topics-items-properties-push_subscriptions.md "Push subscriptions on the topic") – `undefined#/properties/pubsub_topics/items/properties/push_subscriptions`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-secrets.md "https&#x3A;//www") – `undefined#/properties/secrets`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-secrets-items-properties-locations.md "Locations to replicate secret") – `undefined#/properties/secrets/items/properties/locations`
-   [Untitled array in Recipe for resources within projects.](./resources-properties-service_accounts.md "https&#x3A;//www") – `undefined#/properties/service_accounts`
-   [Untitled array in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-outputs.md "Additional outputs to set in outputs") – `undefined#/properties/terraform_addons/properties/outputs`
-   [Untitled array in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-vars.md "Additional vars to set in the deployment in variables") – `undefined#/properties/terraform_addons/properties/vars`
-   [Untitled array in Terraform Deployment Recipe.](./deployment-properties-terraform_addons-properties-deps.md "Additional dependencies on other deployments") – `undefined#/properties/terraform_addons/properties/deps`
