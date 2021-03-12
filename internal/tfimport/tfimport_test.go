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

package tfimport

import (
	"fmt"
	"os/exec"
	"reflect"
	"testing"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfimport/importer"
	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
)

func TestImportable(t *testing.T) {
	tests := []struct {
		rc   terraform.ResourceChange
		pcv  map[string]interface{}
		want resourceImporter
	}{
		// Empty Kind - should return nil.
		{terraform.ResourceChange{}, nil, nil},

		// Unsupported Kind - should return nil.
		{
			terraform.ResourceChange{
				Kind: "unsupported",
			}, nil, nil,
		},

		// Bucket - should return resource with bucket importer
		{
			terraform.ResourceChange{
				Kind:    "google_storage_bucket",
				Address: "google_storage_bucket.gcs_tf_bucket",
				Change: terraform.Change{
					After: map[string]interface{}{
						"project": "project-from-resource",
						"name":    "mybucket",
					},
				},
			}, nil,
			&importer.SimpleImporter{},
		},

		// GKE Cluster - should return resource with GKE cluster importer
		{
			terraform.ResourceChange{
				Kind:    "google_sql_user",
				Address: "google_sql_user.my_user",
				Change: terraform.Change{
					After: map[string]interface{}{
						"project":  "project-from-resource",
						"instance": "instance-from-resource",
						"name":     "name-from-instance",
					},
				},
			}, nil,
			&importer.SQLUser{},
		},
	}
	for _, tc := range tests {
		got, ok := Importable(tc.rc, tc.pcv, false)

		// If we want nil, we should get nil.
		// If we don't want nil, then the address and importer should match.
		if got == nil {
			if tc.want != nil {
				t.Errorf("Importable(%v, %v) = nil; want %+v", tc.rc, tc.pcv, tc.want)
			}
		} else if reflect.TypeOf(got.Importer) != reflect.TypeOf(tc.want) {
			t.Errorf("Importable(%v, %v) = %+v; want %+v", tc.rc, tc.pcv, got.Importer, tc.want)
		} else if !ok {
			t.Errorf("Importable(%v, %v) unexpectedly failed", tc.rc, tc.pcv)
		}
	}
}

const (
	testAddress       = "test-address"
	testImportID      = "test-import-id"
	testInputDir      = "test-input-dir"
	testTerraformPath = "terraform"
)

var argsWant = []string{testTerraformPath, "import", testAddress, testImportID}

type testImporter struct{}

func (r *testImporter) ImportID(terraform.ResourceChange, importer.ConfigMap, bool) (string, error) {
	return testImportID, nil
}

type testRunner struct {
	// This can be modified per test case to check different outcomes.
	output []byte
}

func (*testRunner) CmdRun(cmd *exec.Cmd) error              { return nil }
func (*testRunner) CmdOutput(cmd *exec.Cmd) ([]byte, error) { return nil, nil }
func (tr *testRunner) CmdCombinedOutput(cmd *exec.Cmd) ([]byte, error) {
	if !cmp.Equal(cmd.Args, argsWant) {
		return nil, fmt.Errorf("args = %v; want %v", cmd.Args, argsWant)
	}
	return tr.output, nil
}

func TestImportArgs(t *testing.T) {
	testResource := &Resource{
		Change:         terraform.ResourceChange{Address: testAddress},
		ProviderConfig: importer.ConfigMap{},
		Importer:       &testImporter{},
	}

	wantOutput := ""
	trn := &testRunner{
		output: []byte(wantOutput),
	}

	gotOutput, err := Import(trn, testResource, testInputDir, testTerraformPath, true)

	if err != nil {
		t.Errorf("TestImport(%v, %v, %v) %v", trn, testResource, testInputDir, err)
	}
	if !cmp.Equal(gotOutput, wantOutput) {
		t.Errorf("TestImport(%v, %v, %v) output = %v; want %v", trn, testResource, testInputDir, gotOutput, wantOutput)
	}
}

func TestNotImportable(t *testing.T) {
	tests := []struct {
		output string
		want   bool
	}{
		// No output.
		{
			output: "",
			want:   false,
		},

		// Not importable error.
		{
			output: "Error: resource google_container_registry doesn't support import",
			want:   true,
		},

		// Importable and exists.
		{
			output: "Import successful!",
			want:   false,
		},
	}
	for _, tc := range tests {
		got := NotImportable(tc.output)
		if got != tc.want {
			t.Errorf("TestNotImportable(%v) = %v; want %v", tc.output, got, tc.want)
		}
	}
}

func TestDoesNotExist(t *testing.T) {
	tests := []struct {
		output string
		want   bool
	}{
		// No output.
		{
			output: "",
			want:   false,
		},

		// Does not exist error.
		{
			output: "Error: Cannot import non-existent remote object",
			want:   true,
		},

		// Importable and exists.
		{
			output: "Import successful!",
			want:   false,
		},
	}
	for _, tc := range tests {
		got := DoesNotExist(tc.output)
		if got != tc.want {
			t.Errorf("TestDoesNotExist(%v) = %v; want %v", tc.output, got, tc.want)
		}
	}
}

// Simple sanity tests, they make sure each importer assembles the plan values correctly for the ImportID.
func TestImportersSanity(t *testing.T) {
	tests := []struct {
		resource   string
		planFields map[string]interface{}
		want       string
	}{
		{
			"google_app_engine_application",
			map[string]interface{}{
				"project": "my-appengine-project",
			},
			"my-appengine-project",
		},
		{
			"google_bigquery_dataset",
			map[string]interface{}{
				"project":    "my-bq-project",
				"dataset_id": "my_bq_dataset",
			},
			"projects/my-bq-project/datasets/my_bq_dataset",
		},
		{
			"google_bigquery_table",
			map[string]interface{}{
				"project":    "my-bq-project",
				"dataset_id": "my_bq_dataset",
				"table_id":   "my_bq_table",
			},
			"my-bq-project/my_bq_dataset/my_bq_table",
		},
		{
			"google_billing_account_iam_binding",
			map[string]interface{}{
				"billing_account_id": "my_billing_account",
				"role":               "roles/owner",
			},
			"my_billing_account roles/owner",
		},
		{
			"google_billing_account_iam_member",
			map[string]interface{}{
				"billing_account_id": "my_billing_account",
				"role":               "roles/owner",
				"member":             "user:myuser@example.com",
			},
			"my_billing_account roles/owner user:myuser@example.com",
		},
		{
			"google_billing_account_iam_policy",
			map[string]interface{}{
				"billing_account_id": "my_billing_account",
			},
			"my_billing_account",
		},
		{
			"google_binary_authorization_policy",
			map[string]interface{}{
				"project": "my-binauthz-project",
			},
			"projects/my-binauthz-project",
		},
		{
			"google_cloudbuild_trigger",
			map[string]interface{}{
				"project": "my-cb-project",
				"name":    "my_cb_trigger",
			},
			"projects/my-cb-project/triggers/my_cb_trigger",
		},
		{
			"google_compute_address",
			map[string]interface{}{
				"project": "my-compute-project",
				"region":  "us-east1",
				"name":    "my_address",
			},
			"projects/my-compute-project/regions/us-east1/addresses/my_address",
		},
		{
			"google_compute_firewall",
			map[string]interface{}{
				"project": "my-firewall-project",
				"name":    "my_firewall",
			},
			"projects/my-firewall-project/global/firewalls/my_firewall",
		},
		{
			"google_compute_forwarding_rule",
			map[string]interface{}{
				"project": "my-forwarding-project",
				"region":  "us-east1",
				"name":    "my_forwarding_rule",
			},
			"projects/my-forwarding-project/regions/us-east1/forwardingRules/my_forwarding_rule",
		},
		{
			"google_compute_global_address",
			map[string]interface{}{
				"project": "my-compute-global-project",
				"name":    "my_global_address",
			},
			"projects/my-compute-global-project/global/addresses/my_global_address",
		},
		{
			"google_compute_health_check",
			map[string]interface{}{
				"project": "my-health-check-project",
				"name":    "my_health_check",
			},
			"projects/my-health-check-project/global/healthChecks/my_health_check",
		},
		{
			"google_compute_image",
			map[string]interface{}{
				"project": "my-compute-project",
				"name":    "my_image",
			},
			"projects/my-compute-project/global/images/my_image",
		},
		{
			"google_compute_instance",
			map[string]interface{}{
				"project": "my-compute-project",
				"zone":    "us-east1-a",
				"name":    "my_instance",
			},
			"projects/my-compute-project/zones/us-east1-a/instances/my_instance",
		},
		{
			"google_compute_instance_template",
			map[string]interface{}{
				"project": "my-compute-project",
				"name":    "my_instance_template",
			},
			"projects/my-compute-project/global/instanceTemplates/my_instance_template",
		},
		{
			"google_compute_instance_from_template",
			map[string]interface{}{
				"project": "my-compute-project",
				"zone":    "us-east1-a",
				"name":    "my_instance",
			},
			"projects/my-compute-project/zones/us-east1-a/instances/my_instance",
		},
		{
			"google_compute_interconnect_attachment",
			map[string]interface{}{
				"project": "my-interconnect-project",
				"region":  "us-east1",
				"name":    "my_interconnect_attachment",
			},
			"projects/my-interconnect-project/regions/us-east1/interconnectAttachments/my_interconnect_attachment",
		},
		{
			"google_compute_network",
			map[string]interface{}{
				"project": "my-network-project",
				"name":    "my_network",
			},
			"projects/my-network-project/global/networks/my_network",
		},
		{
			"google_compute_network_peering",
			map[string]interface{}{
				"network": "projects/my-network-project/global/networks/my_network",
				"name":    "my_peering",
			},
			"my-network-project/my_network/my_peering",
		},
		{
			"google_compute_project_metadata_item",
			map[string]interface{}{
				"key": "my_metadata",
			},
			"my_metadata",
		},
		{
			"google_compute_region_backend_service",
			map[string]interface{}{
				"project": "my-backend-project",
				"region":  "us-east1",
				"name":    "my_backend_service",
			},
			"projects/my-backend-project/regions/us-east1/backendServices/my_backend_service",
		},
		{
			"google_compute_route",
			map[string]interface{}{
				"project": "my-route-project",
				"name":    "my-compute-route",
			},
			"projects/my-route-project/global/routes/my-compute-route",
		},
		{
			"google_compute_router",
			map[string]interface{}{
				"project": "my-router-project",
				"region":  "us-east1",
				"name":    "my_router",
			},
			"projects/my-router-project/regions/us-east1/routers/my_router",
		},
		{
			"google_compute_router_interface",
			map[string]interface{}{
				"region": "us-east1",
				"router": "my-router",
				"name":   "my-interface",
			},
			"us-east1/my-router/my-interface",
		},
		{
			"google_compute_router_nat",
			map[string]interface{}{
				"project": "my-router-project",
				"region":  "us-east1",
				"router":  "my_router",
				"name":    "my_nat",
			},
			"projects/my-router-project/regions/us-east1/routers/my_router/my_nat",
		},
		{
			"google_compute_router_peer",
			map[string]interface{}{
				"project": "my-router-project",
				"region":  "us-east1",
				"router":  "my_router",
				"name":    "my_peer",
			},
			"projects/my-router-project/regions/us-east1/routers/my_router/my_peer",
		},
		{
			"google_compute_shared_vpc_host_project",
			map[string]interface{}{
				"project": "my-vpc-project",
			},
			"my-vpc-project",
		},
		{
			"google_compute_shared_vpc_service_project",
			map[string]interface{}{
				"host_project":    "my-host-project",
				"service_project": "my-service-project",
			},
			"my-host-project/my-service-project",
		},
		{
			"google_compute_subnetwork",
			map[string]interface{}{
				"project": "my-subnetwork-project",
				"region":  "us-east1",
				"name":    "my_subnetwork",
			},
			"projects/my-subnetwork-project/regions/us-east1/subnetworks/my_subnetwork",
		},
		{
			"google_compute_subnetwork_iam_binding",
			map[string]interface{}{
				"subnetwork": "projects/my-subnetwork-project/regions/us-east1/subnetworks/my_subnetwork",
				"role":       "roles/owner",
			},
			"projects/my-subnetwork-project/regions/us-east1/subnetworks/my_subnetwork roles/owner",
		},
		{
			"google_compute_subnetwork_iam_member",
			map[string]interface{}{
				"subnetwork": "projects/my-subnetwork-project/regions/us-east1/subnetworks/my_subnetwork",
				"role":       "roles/owner",
				"member":     "user:myuser@example.com",
			},
			"projects/my-subnetwork-project/regions/us-east1/subnetworks/my_subnetwork roles/owner user:myuser@example.com",
		},
		{
			"google_compute_subnetwork_iam_policy",
			map[string]interface{}{
				"subnetwork": "projects/my-network-project/regions/us-east1/subnetworks/my-subnet",
			},
			"projects/my-network-project/regions/us-east1/subnetworks/my-subnet",
		},
		{
			"google_container_cluster",
			map[string]interface{}{
				"project":  "my-gke-project",
				"location": "us-east1-a",
				"name":     "my_cluster",
			},
			"projects/my-gke-project/locations/us-east1-a/clusters/my_cluster",
		},
		{
			"google_container_node_pool",
			map[string]interface{}{
				"project":  "my-gke-project",
				"location": "us-east1-a",
				"cluster":  "my_cluster",
				"name":     "my_node_pool",
			},
			"my-gke-project/us-east1-a/my_cluster/my_node_pool",
		},
		{
			"google_dns_managed_zone",
			map[string]interface{}{
				"project": "my-dns-project",
				"name":    "my_managed_zone",
			},
			"projects/my-dns-project/managedZones/my_managed_zone",
		},
		{
			"google_dns_record_set",
			map[string]interface{}{
				"project":      "my-dns-project",
				"managed_zone": "my_managed_zone",
				"name":         "my_record_set",
				"type":         "A",
			},
			"my-dns-project/my_managed_zone/my_record_set/A",
		},
		{
			"google_firebase_project",
			map[string]interface{}{
				"project": "my-firebase-project",
			},
			"projects/my-firebase-project",
		},
		{
			"google_folder",
			map[string]interface{}{
				"folder_id": "my-folder",
			},
			"folders/my-folder",
		},
		{
			"google_folder_iam_binding",
			map[string]interface{}{
				"folder": "my-folder",
				"role":   "roles/owner",
			},
			"my-folder roles/owner",
		},
		{
			"google_folder_iam_member",
			map[string]interface{}{
				"folder": "my-folder",
				"role":   "roles/owner",
				"member": "user:myuser@example.com",
			},
			"my-folder roles/owner user:myuser@example.com",
		},
		{
			"google_folder_iam_policy",
			map[string]interface{}{
				"folder": "my-folder",
			},
			"my-folder",
		},
		{
			"google_folder_organization_policy",
			map[string]interface{}{
				"folder":     "my-folder",
				"constraint": "serviceuser.services",
			},
			"folders/my-folder/constraints/serviceuser.services",
		},
		{
			"google_iap_tunnel_instance_iam_binding",
			map[string]interface{}{
				"project":  "my-iap-project",
				"zone":     "us-east1-a",
				"instance": "my_tunnel_instance",
				"role":     "roles/iap.tunnelResourceAccessor",
			},
			"projects/my-iap-project/iap_tunnel/zones/us-east1-a/instances/my_tunnel_instance roles/iap.tunnelResourceAccessor",
		},
		{
			"google_iap_tunnel_instance_iam_member",
			map[string]interface{}{
				"project":  "my-iap-project",
				"zone":     "us-east1-a",
				"instance": "my_tunnel_instance",
				"role":     "roles/iap.tunnelResourceAccessor",
				"member":   "user:myuser@example.com",
			},
			"projects/my-iap-project/iap_tunnel/zones/us-east1-a/instances/my_tunnel_instance roles/iap.tunnelResourceAccessor user:myuser@example.com",
		},
		{
			"google_iap_tunnel_instance_iam_policy",
			map[string]interface{}{
				"project":  "my-iap-project",
				"zone":     "us-east1-a",
				"instance": "my_tunnel_instance",
			},
			"projects/my-iap-project/iap_tunnel/zones/us-east1-a/instances/my_tunnel_instance",
		},
		{
			"google_kms_key_ring",
			map[string]interface{}{
				"project":  "my-kms-project",
				"location": "us-east1",
				"name":     "my_kms_key_ring",
			},
			"projects/my-kms-project/locations/us-east1/keyRings/my_kms_key_ring",
		},
		{
			"google_logging_billing_account_sink",
			map[string]interface{}{
				"billing_account": "my-billing-account",
				"name":            "my_sink",
			},
			"billingAccounts/my-billing-account/sinks/my_sink",
		},
		{
			"google_logging_folder_sink",
			map[string]interface{}{
				"folder": "my-folder",
				"name":   "my_sink",
			},
			"folders/my-folder/sinks/my_sink",
		},
		{
			"google_logging_metric",
			map[string]interface{}{
				"project": "my-project",
				"name":    "my-metric",
			},
			"my-project my-metric",
		},
		{
			"google_logging_organization_sink",
			map[string]interface{}{
				"org_id": "my-org",
				"name":   "my_sink",
			},
			"organizations/my-org/sinks/my_sink",
		},
		{
			"google_logging_project_sink",
			map[string]interface{}{
				"project": "my-project",
				"name":    "my_sink",
			},
			"projects/my-project/sinks/my_sink",
		},
		{
			"google_organization_iam_audit_config",
			map[string]interface{}{
				"org_id":  "my-org",
				"service": "iam.googleapis.com",
			},
			"my-org iam.googleapis.com",
		},
		{
			"google_organization_iam_custom_role",
			map[string]interface{}{
				"org_id":  "my-org",
				"role_id": "my_custom_role",
			},
			"organizations/my-org/roles/my_custom_role",
		},
		{
			"google_organization_iam_member",
			map[string]interface{}{
				"org_id": "my-org",
				"role":   "roles/owner",
				"member": "user:myuser@example.com",
			},
			"my-org roles/owner user:myuser@example.com",
		},
		{
			"google_organization_policy",
			map[string]interface{}{
				"org_id":     "my-org",
				"constraint": "serviceuser.services",
			},
			"my-org/constraints/serviceuser.services",
		},
		{
			"google_project",
			map[string]interface{}{
				"project_id": "my-project",
			},
			"my-project",
		},
		{
			"google_project_iam_audit_config",
			map[string]interface{}{
				"project": "my-project",
				"service": "allServices",
			},
			"my-project allServices",
		},
		{
			"google_project_iam_binding",
			map[string]interface{}{
				"project": "my-project",
				"role":    "roles/owner",
			},
			"my-project roles/owner",
		},
		{
			"google_project_iam_custom_role",
			map[string]interface{}{
				"project": "my-project",
				"role_id": "my_custom_role",
			},
			"projects/my-project/roles/my_custom_role",
		},
		{
			"google_project_iam_member",
			map[string]interface{}{
				"project": "my-project",
				"role":    "roles/owner",
				"member":  "user:myuser@example.com",
			},
			"my-project roles/owner user:myuser@example.com",
		},
		{
			"google_project_organization_policy",
			map[string]interface{}{
				"project":    "my-project",
				"constraint": "serviceuser.services",
			},
			"projects/my-project:constraints/serviceuser.services",
		},
		{
			"google_project_service",
			map[string]interface{}{
				"project": "my-project",
				"service": "iam.googleapis.com",
			},
			"my-project/iam.googleapis.com",
		},
		{
			"google_project_usage_export_bucket",
			map[string]interface{}{
				"project": "my-project",
			},
			"my-project",
		},
		{
			"google_pubsub_subscription",
			map[string]interface{}{
				"project": "my-project",
				"name":    "my-subscription",
			},
			"projects/my-project/subscriptions/my-subscription",
		},
		{
			"google_pubsub_subscription_iam_binding",
			map[string]interface{}{
				"project":      "my-project",
				"subscription": "my-subscription",
				"role":         "roles/owner",
			},
			"projects/my-project/subscriptions/my-subscription roles/owner",
		},
		{
			"google_pubsub_subscription_iam_member",
			map[string]interface{}{
				"project":      "my-project",
				"subscription": "my-subscription",
				"role":         "roles/owner",
				"member":       "user:myuser@example.com",
			},
			"projects/my-project/subscriptions/my-subscription roles/owner user:myuser@example.com",
		},
		{
			"google_pubsub_subscription_iam_policy",
			map[string]interface{}{
				"project":      "my-project",
				"subscription": "my-subscription",
			},
			"projects/my-project/subscriptions/my-subscription",
		},
		{
			"google_pubsub_topic",
			map[string]interface{}{
				"project": "my-project",
				"name":    "my-topic",
			},
			"projects/my-project/topics/my-topic",
		},
		{
			"google_pubsub_topic_iam_binding",
			map[string]interface{}{
				"project": "my-project",
				"topic":   "my-topic",
				"role":    "roles/owner",
			},
			"projects/my-project/topics/my-topic roles/owner",
		},
		{
			"google_pubsub_topic_iam_member",
			map[string]interface{}{
				"project": "my-project",
				"topic":   "my-topic",
				"role":    "roles/owner",
				"member":  "user:myuser@example.com",
			},
			"projects/my-project/topics/my-topic roles/owner user:myuser@example.com",
		},
		{
			"google_pubsub_topic_iam_policy",
			map[string]interface{}{
				"project": "my-project",
				"topic":   "my-topic",
			},
			"projects/my-project/topics/my-topic",
		},
		{
			"google_secret_manager_secret",
			map[string]interface{}{
				"project":   "my-project",
				"secret_id": "my-secret",
			},
			"projects/my-project/secrets/my-secret",
		},
		{
			"google_secret_manager_secret_version",
			map[string]interface{}{
				"secret": "projects/my-project/secrets/my-secret",
			},
			"projects/my-project/secrets/my-secret/versions/latest",
		},
		{
			"google_service_account",
			map[string]interface{}{
				"project":    "my-project",
				"account_id": "my-sa",
			},
			"projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com",
		},
		{
			"google_service_account_iam_binding",
			map[string]interface{}{
				"service_account_id": "projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com",
				"role":               "roles/owner",
			},
			"projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com roles/owner",
		},
		{
			"google_service_account_iam_member",
			map[string]interface{}{
				"service_account_id": "projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com",
				"role":               "roles/owner",
				"member":             "user:myuser@example.com",
			},
			"projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com roles/owner user:myuser@example.com",
		},
		{
			"google_service_account_iam_policy",
			map[string]interface{}{
				"service_account_id": "projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com",
			},
			"projects/my-project/serviceAccounts/my-sa@my-project.iam.gserviceaccount.com",
		},
		{
			"google_service_usage_consumer_quota_override",
			map[string]interface{}{
				"project": "my-project",
				"service": "healthcare.googleapis.com",
				"metric":  "healthcare.googleapis.com%2Fannotation_ops",
				"limit":   "%2Fmin%2Fproject%2Fregion",
				"name":    "server-generated",
			},
			"projects/my-project/services/healthcare.googleapis.com/consumerQuotaMetrics/healthcare.googleapis.com%2Fannotation_ops/limits/%2Fmin%2Fproject%2Fregion/consumerOverrides/server-generated",
		},
		{
			"google_sql_database",
			map[string]interface{}{
				"project":  "my-project",
				"instance": "my-instance",
				"name":     "my-db",
			},
			"projects/my-project/instances/my-instance/databases/my-db",
		},
		{
			"google_sql_database_instance",
			map[string]interface{}{
				"project": "my-project",
				"name":    "my-instance",
			},
			"projects/my-project/instances/my-instance",
		},
		{
			"google_storage_bucket",
			map[string]interface{}{
				"project": "my-project",
				"name":    "my-bucket",
			},
			"my-project/my-bucket",
		},
		{
			"google_storage_bucket_iam_binding",
			map[string]interface{}{
				"bucket": "my-bucket",
				"role":   "roles/owner",
			},
			"my-bucket roles/owner",
		},
		{
			"google_storage_bucket_iam_member",
			map[string]interface{}{
				"bucket": "my-bucket",
				"role":   "roles/owner",
				"member": "user:myuser@example.com",
			},
			"my-bucket roles/owner user:myuser@example.com",
		},
		{
			"google_storage_bucket_iam_policy",
			map[string]interface{}{
				"bucket": "my-bucket",
			},
			"my-bucket",
		},
		{
			"gsuite_group",
			map[string]interface{}{
				"email": "mygsuitegroup@example.com",
			},
			"mygsuitegroup@example.com",
		},
		{
			"gsuite_group_member",
			map[string]interface{}{
				"group": "mygsuitegroup@example.com",
				"email": "mygsuiteuser@example.com",
			},
			"mygsuitegroup@example.com:mygsuiteuser@example.com",
		},
		{
			"helm_release",
			map[string]interface{}{
				"namespace": "my-namespace",
				"name":      "my-helm-release",
			},
			"my-namespace/my-helm-release",
		},
		{
			"helm_release",
			map[string]interface{}{
				"name": "my-helm-release",
			},
			"default/my-helm-release",
		},
		{
			"kubernetes_config_map",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"namespace": "my-namespace",
					"name":      "my-config-map",
				},
			},
			"my-namespace/my-config-map",
		},
		{
			"kubernetes_config_map",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"name": "my-config-map",
				},
			},
			"default/my-config-map",
		},
		{
			"kubernetes_manifest",
			map[string]interface{}{
				"manifest": map[string]interface{}{
					"metadata": map[string]interface{}{
						"namespace": "my-namespace",
						"name":      "my-kubernetes-resource",
					},
				},
			},
			"my-namespace/my-kubernetes-resource",
		},
		{
			"kubernetes_manifest",
			map[string]interface{}{
				"manifest": map[string]interface{}{
					"metadata": map[string]interface{}{
						"name": "my-kubernetes-resource",
					},
				},
			},
			"default/my-kubernetes-resource",
		},
		{
			"kubernetes_namespace",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"name": "my-namespace",
				},
			},
			"my-namespace",
		},
		{
			"kubernetes_pod",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"namespace": "my-namespace",
					"name":      "my-kubernetes-resource",
				},
			},
			"my-namespace/my-kubernetes-resource",
		},
		{
			"kubernetes_role",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"namespace": "my-namespace",
					"name":      "my-kubernetes-resource",
				},
			},
			"my-namespace/my-kubernetes-resource",
		},
		{
			"kubernetes_role_binding",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"namespace": "my-namespace",
					"name":      "my-kubernetes-resource",
				},
			},
			"my-namespace/my-kubernetes-resource",
		},
		{
			"kubernetes_service",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"namespace": "my-namespace",
					"name":      "my-kubernetes-resource",
				},
			},
			"my-namespace/my-kubernetes-resource",
		},
		{
			"kubernetes_service_account",
			map[string]interface{}{
				"metadata": map[string]interface{}{
					"namespace": "my-namespace",
					"name":      "my-kubernetes-resource",
				},
			},
			"my-namespace/my-kubernetes-resource",
		},
	}
	for _, tc := range tests {
		importer, ok := Importers[tc.resource]
		if !ok {
			t.Fatalf("importer does not exist for %v", tc.resource)
		}

		change := terraform.ResourceChange{Change: terraform.Change{After: tc.planFields}}
		got, err := importer.ImportID(change, nil, false)
		if err != nil {
			t.Fatalf("%v importer %T(%v, nil, false) returned error: %v", tc.resource, importer, change, err)
		}
		if diff := cmp.Diff(tc.want, got, cmpopts.EquateEmpty()); diff != "" {
			t.Errorf("%v importer %T(%v, nil, false) returned diff (-want +got):\n%s", tc.resource, importer, change, diff)
		}
	}
}

// The template is looking for a field that isn't required by the importer.
// This should cause the template to fail.
func TestSimpleImporterTmplExtraField(t *testing.T) {
	imp := &importer.SimpleImporter{
		Fields: []string{"project", "role"},
		Tmpl:   "{{.project}} {{.role}} {{.member}}",
	}

	fields := map[string]interface{}{
		"project": "my-project",
		"role":    "roles/owner",
	}
	change := terraform.ResourceChange{Change: terraform.Change{After: fields}}
	_, err := imp.ImportID(change, nil, false)
	if err == nil {
		t.Errorf("importer %v ImportID(%v, nil, false) succeeded for malformed input, want error", imp, change)
	}
}

// The importer requires a field that isn't being passed in.
// This should cause the template to fail.
func TestSimpleImporterRequiredFieldMissing(t *testing.T) {
	imp := &importer.SimpleImporter{
		Fields: []string{"project", "role", "member"},
		Tmpl:   "{{.project}} {{.role}} {{.member}}",
	}

	fields := map[string]interface{}{
		"project": "my-project",
		"role":    "roles/owner",
	}
	change := terraform.ResourceChange{Change: terraform.Change{After: fields}}
	_, err := imp.ImportID(change, nil, false)
	if err == nil {
		t.Errorf("importer %v ImportID(%v, nil, false) succeeded for malformed input, want error", imp, change)
	}
}
