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
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/licenseutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/otiai10/copy"
)

const (
	forsetiOutputRoot     = "forseti_policies"
	orgPoliciesOutputRoot = "gcp_org_policies"
)

// RunArgs is the struct representing the arguments passed to Run().
type RunArgs struct {
	ConfigPath string
	StatePath  string
	OutputPath string
}

func Run(ctx context.Context, rn runner.Runner, args *RunArgs) error {
	var err error
	configPath, err := pathutil.Expand(args.ConfigPath)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", args.ConfigPath, err)
	}

	statePath, err := pathutil.Expand(args.StatePath)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", args.StatePath, err)
	}

	outputPath, err := pathutil.Expand(args.OutputPath)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", args.OutputPath, err)
	}

	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	c, err := loadConfig(configPath)
	if err != nil {
		return fmt.Errorf("load config: %v", err)
	}

	if err := generateGCPOrgPolicies(tmpDir, c); err != nil {
		return fmt.Errorf("generate GCP organization policies: %v", err)
	}

	if err := generateForsetiPolicies(ctx, rn, statePath, tmpDir, c); err != nil {
		return fmt.Errorf("generate Forseti policies: %v", err)
	}

	if err := licenseutil.AddLicense(tmpDir); err != nil {
		return fmt.Errorf("add license header: %v", err)
	}

	if err := os.MkdirAll(outputPath, 0755); err != nil {
		return fmt.Errorf("mkdir %q: %v", outputPath, err)
	}

	return copy.Copy(tmpDir, outputPath)
}

func generateGCPOrgPolicies(outputPath string, c *config) error {
	if c.GCPOrgPolicies == nil {
		return nil
	}

	in := filepath.Join(c.TemplateDir, "org_policies")
	out := filepath.Join(outputPath, orgPoliciesOutputRoot)
	return template.WriteDir(in, out, c.GCPOrgPolicies)
}

func generateForsetiPolicies(ctx context.Context, rn runner.Runner, statePath, outputPath string, c *config) error {
	if c.ForsetiPolicies == nil {
		return nil
	}

	if err := generateGeneralForsetiPolicies(outputPath, c); err != nil {
		return err
	}

	if err := generateTerraformBasedForsetiPolicies(ctx, rn, statePath, outputPath, c.TemplateDir); err != nil {
		return err
	}

	return nil
}

func generateGeneralForsetiPolicies(outputPath string, c *config) error {
	in := filepath.Join(c.TemplateDir, "forseti", "overall")
	out := filepath.Join(outputPath, forsetiOutputRoot, "overall")
	return template.WriteDir(in, out, c.ForsetiPolicies)
}

func generateTerraformBasedForsetiPolicies(ctx context.Context, rn runner.Runner, statePath, outputPath, templateDir string) error {
	if statePath == "" {
		log.Println("No Terraform state given, only generating Terraform-agnostic security policies")
		return nil
	}

	resources, err := loadResources(ctx, statePath)
	if err != nil {
		return err
	}

	return generateIAMPolicies(rn, resources, outputPath, templateDir)
}
