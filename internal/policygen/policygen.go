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

// Package policygen implements the Policy Generator.
package policygen

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
)

func Run(inputConfig, inputDir, inputPlan, inputState, outputDir string) error {
	var err error
	inputConfig, err = pathutil.Expand(inputConfig)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", inputConfig, err)
	}

	outputDir, err = pathutil.Expand(outputDir)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", outputDir, err)
	}

	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	c, err := loadConfig(inputConfig)
	if err != nil {
		return fmt.Errorf("load config: %v", err)
	}

	if err := generateGCPOrgPolicies(tmpDir, c); err != nil {
		return fmt.Errorf("generate GCP organization policies: %v", err)
	}

	if err := generateForsetiPolicies(tmpDir, c); err != nil {
		return fmt.Errorf("generate Forseti policies: %v", err)
	}

	rn := &runner.Default{Quiet: true}
	resources, err := loadResources(rn, inputDir, inputPlan, inputState)
	if err != nil {
		return err
	}
	log.Printf("Found %d resources from input Terraform resources", len(resources))

	// TODO: generate policies that rely on input config.

	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("mkdir %q: %v", outputDir, err)
	}

	fs, err := filepath.Glob(filepath.Join(tmpDir, "*"))
	if err != nil {
		return err
	}
	cp := exec.Command("cp", append([]string{"-a", "-t", outputDir}, fs...)...)
	return rn.CmdRun(cp)
}

func generateForsetiPolicies(outputDir string, c *config) error {
	if c.ForsetiPolicies == nil {
		return nil
	}

	data := map[string]interface{}{
		"ORG_ID": c.OrgID,
	}
	in := filepath.Join(c.TemplateDir, "forseti", "org")
	out := filepath.Join(outputDir, "forseti_policies", fmt.Sprintf("org.%s", c.OrgID))
	return template.WriteDir(in, out, data)
}

func generateGCPOrgPolicies(outputDir string, c *config) error {
	if c.GCPOrgPolicies == nil {
		return nil
	}
	data := map[string]interface{}{
		"ORG_ID": c.OrgID,
	}

	if err := template.MergeData(data, c.GCPOrgPolicies, nil); err != nil {
		return err
	}

	in := filepath.Join(c.TemplateDir, "org_policies")
	out := filepath.Join(outputDir, "gcp_organization_policies")
	if err := template.WriteDir(in, out, data); err != nil {
		return err
	}
	return nil
}
