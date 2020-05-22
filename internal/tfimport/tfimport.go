// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Package tfimport provides utilities to import resources from a Terraform config.
package tfimport

import (
	"os/exec"
	"regexp"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport/importer"
)

// Regexes used in parsing the output of the `terraform import` command.
var (
	reNotImportable = regexp.MustCompile(`(?i)Error:.*resource (.*) doesn't support import`)
	reDoesNotExist  = regexp.MustCompile(`(?i)Error:.*Cannot import non-existent.*object`)
)

// Defines all supported resource importers
// TODO: Add more resources
var importers = map[string]resourceImporter{
	"random_id": &importer.RandomID{},
	"google_storage_bucket": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "{{.project}}/{{.name}}",
	},
	"google_container_cluster": &importer.SimpleImporter{
		Fields: []string{"project", "location", "name"},
		Tmpl:   "projects/{{.project}}/locations/{{.location}}/clusters/{{.name}}",
	},
	"google_organization_policy": &importer.SimpleImporter{
		Fields: []string{"org_id", "constraint"},
		Tmpl:   "{{.org_id}}/{{.constraint}}",
	},
	"google_organization_iam_member": &importer.SimpleImporter{
		Fields: []string{"org_id", "role", "member"},
		Tmpl:   "{{.org_id}} {{.role}} {{.member}}",
	},
	"google_organization_iam_audit_config": &importer.SimpleImporter{
		Fields: []string{"org_id", "service"},
		Tmpl:   "{{.org_id}} {{.service}}",
	},
	"google_project": &importer.SimpleImporter{
		Fields: []string{"project_id"},
		Tmpl:   "{{.project_id}}",
	},
	"google_project_iam_binding": &importer.SimpleImporter{
		Fields: []string{"project", "role"},
		Tmpl:   "{{.project}} {{.role}}",
	},
	"google_project_iam_member": &importer.SimpleImporter{
		Fields: []string{"project", "role", "member"},
		Tmpl:   "{{.project}} {{.role}} {{.member}}",
	},
	"google_project_service": &importer.SimpleImporter{
		Fields: []string{"project", "service"},
		Tmpl:   "{{.project}}/{{.service}}",
	},
	"google_service_account": &importer.SimpleImporter{
		Fields: []string{"project", "account_id"},
		Tmpl:   "projects/{{.project}}/serviceAccounts/{{.account_id}}@{{.project}}.iam.gserviceaccount.com",
	},
	"google_bigquery_table": &importer.SimpleImporter{
		Fields: []string{"project", "dataset_id", "table_id"},
		Tmpl:   "{{.project}}/{{.dataset_id}}/{{.table_id}}",
	},
	"google_bigquery_dataset": &importer.SimpleImporter{
		Fields: []string{"project", "dataset_id"},
		Tmpl:   "projects/{{.project}}/datasets/{{.dataset_id}}",
	},
	"google_storage_bucket_iam_member": &importer.SimpleImporter{
		Fields: []string{"bucket", "role", "member"},
		Tmpl:   "{{.bucket}} {{.role}} {{.member}}",
	},
	"google_cloudbuild_trigger": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/triggers/{{.name}}",
	},
	"google_logging_organization_sink": &importer.SimpleImporter{
		Fields: []string{"org_id", "name"},
		Tmpl:   "organizations/{{.org_id}}/sinks/{{.name}}",
	},
	"google_compute_network": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/global/networks/{{.name}}",
	},
	"google_compute_subnetwork": &importer.SimpleImporter{
		Fields: []string{"project", "region", "name"},
		Tmpl:   "projects/{{.project}}/regions/{{.region}}/subnetworks/{{.name}}",
	},
	"google_compute_router": &importer.SimpleImporter{
		Fields: []string{"project", "region", "name"},
		Tmpl:   "projects/{{.project}}/regions/{{.region}}/routers/{{.name}}",
	},
	"google_compute_router_nat": &importer.SimpleImporter{
		Fields: []string{"project", "region", "router", "name"},
		Tmpl:   "projects/{{.project}}/regions/{{.region}}/routers/{{.router}}/{{.name}}",
	},
	"google_compute_subnetwork_iam_policy": &importer.SimpleImporter{
		Fields: []string{"subnetwork"},
		Tmpl:   "{{.subnetwork}}",
	},
	"google_compute_subnetwork_iam_binding": &importer.SimpleImporter{
		Fields: []string{"subnetwork", "role"},
		Tmpl:   "{{.subnetwork}} {{.role}}",
	},
	"google_compute_subnetwork_iam_member": &importer.SimpleImporter{
		Fields: []string{"subnetwork", "role", "member"},
		Tmpl:   "{{.subnetwork}} {{.role}} {{.member}}",
	},
	"google_dns_managed_zone": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/managedZones/{{.name}}",
	},
	"google_dns_record_set": &importer.SimpleImporter{
		Fields: []string{"project", "managed_zone", "name", "type"},
		Tmpl:   "{{.project}}/{{.managed_zone}}/{{.name}}/{{.type}}",
	},
	"google_firebase_project": &importer.SimpleImporter{
		Fields: []string{"project"},
		Tmpl:   "projects/{{.project}}",
	},
	"google_project_iam_custom_role": &importer.SimpleImporter{
		Fields: []string{"project", "role_id"},
		Tmpl:   "projects/{{.project}}/roles/{{.role_id}}",
	},
	"google_container_node_pool": &importer.SimpleImporter{
		Fields: []string{"project", "location", "cluster", "name"},
		Tmpl:   "{{.project}}/{{.location}}/{{.cluster}}/{{.name}}",
	},
	"google_pubsub_topic": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/topics/{{.name}}",
	},
	"google_pubsub_subscription": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/subscriptions/{{.name}}",
	},
	"google_secret_manager_secret": &importer.SimpleImporter{
		Fields: []string{"project", "secret_id"},
		Tmpl:   "projects/{{.project}}/secrets/{{.secret_id}}",
	},
	"google_secret_manager_secret_version": &importer.SimpleImporter{
		// This field is the full path of the secret, including the project name.
		Fields: []string{"secret"},
		Tmpl:   "{{.secret}}/versions/latest",
	},
	"google_service_account_iam_policy": &importer.SimpleImporter{
		// This already includes the project. It looks like this:
		// projects/my-network-project/serviceAccounts/my-sa@my-network-project.iam.gserviceaccount.com
		Fields: []string{"service_account_id"},
		Tmpl:   "{{.service_account_id}}",
	},
	"google_service_account_iam_binding": &importer.SimpleImporter{
		// This already includes the project. It looks like this:
		// projects/my-network-project/serviceAccounts/my-sa@my-network-project.iam.gserviceaccount.com
		Fields: []string{"service_account_id"},
		Tmpl:   "{{.service_account_id}} roles/iam.serviceAccountUser",
	},
	"google_service_account_iam_member": &importer.SimpleImporter{
		// The service_account_id already includes the project. It looks like this:
		// projects/my-network-project/serviceAccounts/my-sa@my-network-project.iam.gserviceaccount.com
		Fields: []string{"service_account_id", "role", "member"},
		Tmpl:   "{{.service_account_id}} {{.role}} {{.member}}",
	},
	"google_service_networking_connection": &importer.ServiceNetworkingConnection{},
	"google_sql_database": &importer.SimpleImporter{
		Fields: []string{"project", "instance", "name"},
		Tmpl:   "projects/{{.project}}/instances/{{.instance}}/databases/{{.name}}",
	},
	"google_sql_database_instance": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/instances/{{.name}}",
	},
	"google_sql_user": &importer.SQLUser{},
	"google_iap_tunnel_instance_iam_policy": &importer.SimpleImporter{
		Fields: []string{"project", "zone", "instance"},
		Tmpl:   "projects/{{.project}}/iap_tunnel/zones/{{.zone}}/instances/{{.instance}}",
	},
	"google_iap_tunnel_instance_iam_binding": &importer.SimpleImporter{
		Fields: []string{"project", "zone", "instance", "role"},
		Tmpl:   "projects/{{.project}}/iap_tunnel/zones/{{.zone}}/instances/{{.instance}} {{.role}}",
	},
	"google_iap_tunnel_instance_iam_member": &importer.SimpleImporter{
		Fields: []string{"project", "zone", "instance", "role", "member"},
		Tmpl:   "projects/{{.project}}/iap_tunnel/zones/{{.zone}}/instances/{{.instance}} {{.role}} {{.member}}",
	},
	"google_binary_authorization_policy": &importer.SimpleImporter{
		Fields: []string{"project"},
		Tmpl:   "projects/{{.project}}",
	},
	"google_compute_firewall": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/global/firewalls/{{.name}}",
	},
	"google_compute_global_address": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/global/addresses/{{.name}}",
	},
	"google_compute_image": &importer.SimpleImporter{
		Fields: []string{"project", "name"},
		Tmpl:   "projects/{{.project}}/global/images/{{.name}}",
	},
	"google_compute_instance_from_template": &importer.SimpleImporter{
		Fields: []string{"project", "zone", "name"},
		Tmpl:   "projects/{{.project}}/zones/{{.zone}}/instances/{{.name}}",
	},
	"google_compute_shared_vpc_host_project": &importer.SimpleImporter{
		Fields: []string{"project"},
		Tmpl:   "{{.project}}",
	},
	"google_compute_shared_vpc_service_project": &importer.SimpleImporter{
		Fields: []string{"host_project", "service_project"},
		Tmpl:   "{{.host_project}}/{{.service_project}}",
	},
}

// Resource represents a resource and an importer that can import it.
type Resource struct {
	Change         terraform.ResourceChange
	ProviderConfig importer.ProviderConfigMap
	Importer       resourceImporter
}

// resourceImporter is an interface that must be implemented by all resources to allow them to be imported.
type resourceImporter interface {
	// ImportID returns an ID that Terraform can use to import this resource.
	ImportID(rc terraform.ResourceChange, pcv importer.ProviderConfigMap, interactive bool) (string, error)
}

// ImportID is a convenience function for passing a resource's information to its importer.
func (ir Resource) ImportID(interactive bool) (string, error) {
	return ir.Importer.ImportID(ir.Change, ir.ProviderConfig, interactive)
}

// Importable returns an importable Resource which contains an Importer, and whether it successfully created that resource.
// pcv represents provider config values, which will be used if the resource does not have values defined.
func Importable(rc terraform.ResourceChange, pcv importer.ProviderConfigMap) (*Resource, bool) {
	ri, ok := importers[rc.Kind]
	if !ok {
		return nil, false
	}

	return &Resource{
		Change:         rc,
		ProviderConfig: pcv,
		Importer:       ri,
	}, true
}

// Import runs `terraform import` for the given importable resource.
// It parses the output string to determine to determine if the provider said the resource doesn't exist or isn't importable.
func Import(rn runner.Runner, ir *Resource, inputDir string, terraformPath string, interactive bool) (output string, err error) {
	// Try to get the ImportID()
	importID, err := ir.ImportID(interactive)
	if err != nil {
		return output, err
	}

	// Run the import.
	cmd := exec.Command(terraformPath, "import", ir.Change.Address, importID)
	cmd.Dir = inputDir

	outputBytes, err := rn.CmdCombinedOutput(cmd)
	return string(outputBytes), err
}

// NotImportable parses the output of a `terraform import` command to determine if it indicated that a resource is not importable.
func NotImportable(output string) bool {
	return reNotImportable.FindStringIndex(output) != nil
}

// DoesNotExist parses the output of a `terraform import` command to determine if it indicated that a resource does not exist.
func DoesNotExist(output string) bool {
	return reDoesNotExist.FindStringIndex(output) != nil
}
