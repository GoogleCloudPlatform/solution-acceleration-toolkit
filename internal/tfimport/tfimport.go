/*
 * Copyright 2020 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
	"google_storage_bucket":                &importer.StorageBucket{},
	"google_container_cluster":             &importer.GKECluster{},
	"google_organization_policy":           &importer.OrgPolicy{},
	"google_organization_iam_member":       &importer.OrgIAMMember{},
	"google_organization_iam_audit_config": &importer.OrgIAMAuditConfig{},
	"google_project":                       &importer.Project{},
	"google_project_iam_binding":           &importer.ProjectIAMBinding{},
	"google_project_iam_member":            &importer.ProjectIAMMember{},
	"google_project_service":               &importer.ProjectService{},
	"google_service_account":               &importer.ServiceAccount{},
	"google_bigquery_table":                &importer.BigQueryTable{},
	"google_bigquery_dataset":              &importer.BigQueryDataset{},
	"google_cloudbuild_trigger":            &importer.CloudBuildTrigger{},
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
	ImportID(rc terraform.ResourceChange, pcv importer.ProviderConfigMap) (string, error)
}

// ImportID is a convenience function for passing a resource's information to its importer.
func (ir Resource) ImportID() (string, error) {
	return ir.Importer.ImportID(ir.Change, ir.ProviderConfig)
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
func Import(rn runner.Runner, ir *Resource, inputDir string, terraformPath string) (output []byte, err error) {
	// Try to get the ImportID()
	importID, err := ir.ImportID()
	if err != nil {
		return output, err
	}

	// Run the import.
	cmd := exec.Command(terraformPath, "import", ir.Change.Address, importID)
	cmd.Dir = inputDir
	return rn.CmdCombinedOutput(cmd)
}

// NotImportable parses the output of a `terraform import` command to determine if it indicated that a resource is not importable.
func NotImportable(output []byte) bool {
	return reNotImportable.FindStringIndex(string(output)) != nil
}

// DoesNotExist parses the output of a `terraform import` command to determine if it indicated that a resource does not exist.
func DoesNotExist(output []byte) bool {
	return reDoesNotExist.FindStringIndex(string(output)) != nil
}
