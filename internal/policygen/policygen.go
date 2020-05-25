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
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/otiai10/copy"
)

// RunArgs is the struct representing the arguments passed to Run().
type RunArgs struct {
	InputConfig string
	InputState  string
	OutputDir   string
}

func Run(args *RunArgs) error {
	var err error
	inputConfig, err := pathutil.Expand(args.InputConfig)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", args.InputConfig, err)
	}

	outputDir, err := pathutil.Expand(args.OutputDir)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", args.OutputDir, err)
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

	if err := generateForsetiPolicies(args.InputState, tmpDir, c); err != nil {
		return fmt.Errorf("generate Forseti policies: %v", err)
	}

	if err := os.MkdirAll(outputDir, 0755); err != nil {
		return fmt.Errorf("mkdir %q: %v", outputDir, err)
	}

	return copy.Copy(tmpDir, outputDir)
}

func generateGCPOrgPolicies(outputDir string, c *config) error {
	if c.Overall.GCPOrgPolicies == nil {
		return nil
	}

	data, err := mergeData(c)
	if err != nil {
		return fmt.Errorf("merge input data: %v", err)
	}

	in := filepath.Join(c.TemplateDir, "org_policies")
	out := filepath.Join(outputDir, "gcp_org_policies")
	return template.WriteDir(in, out, data)
}

func generateForsetiPolicies(inputState, outputDir string, c *config) error {
	if c.Overall.ForsetiPolicies == nil {
		return nil
	}

	if err := generateGeneralForsetiPolicies(outputDir, c); err != nil {
		return err
	}

	if err := generateTerraformBasedForsetiPolicies(inputState, outputDir); err != nil {
		return err
	}

	return nil
}

func generateGeneralForsetiPolicies(outputDir string, c *config) error {
	data, err := mergeData(c)
	if err != nil {
		return fmt.Errorf("merge input data: %v", err)
	}

	in := filepath.Join(c.TemplateDir, "forseti", "org")
	out := filepath.Join(outputDir, "forseti_policies", "overall")
	return template.WriteDir(in, out, data)
}

func generateTerraformBasedForsetiPolicies(inputState, outputDir string) error {
	if inputState == "" {
		log.Println("No Terraform state given, only generating Terraform-agnostic security policies")
		return nil
	}

	resources, err := loadResources(inputState)
	if err != nil {
		return err
	}

	return generateIAMBindingsPolicies(resources, outputDir)
}

func mergeData(c *config) (map[string]interface{}, error) {
	inputs := []map[string]interface{}{
		c.Overall.ForsetiPolicies,
		c.Overall.GCPOrgPolicies,
		c.IAM,
		c.Compute,
	}

	data := make(map[string]interface{})
	for _, i := range inputs {
		if err := template.MergeData(data, i, nil); err != nil {
			return nil, err
		}
	}

	return data, nil
}
