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

// policygen automates generation of Google-recommended Policy Library constraints based on your Terraform configs.
//
// Usage:
// $ policygen --input_config=./samples/config.yaml --output_dir=/tmp/constraints {--input_dir=/path/to/configs/dir|--input_plan=/path/to/plan/json|--input_state=/path/to/state/json}
package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/pathutil"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/runner"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/template"
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/ghodss/yaml"
)

var (
	inputConfig = flag.String("input_config", "", "Path to the Policy Generator config.")
	inputDir    = flag.String("input_dir", "", "Path to Terraform configs root directory. Cannot be specified together with other types of inputs.")
	inputPlan   = flag.String("input_plan", "", "Path to Terraform plan in json format, Cannot be specified together with other types of inputs.")
	inputState  = flag.String("input_state", "", "Path to Terraform state in json format. Cannot be specified together with other types of inputs.")
	outputDir   = flag.String("output_dir", "", "Path to directory to write generated policies")
)

// Config is the struct representing the Policy Generator configuration.
type Config struct {
	OrgID           string                 `json:"org_id"`
	TemplateDir     string                 `json:"template_dir"`
	ForsetiPolicies map[string]interface{} `json:"forseti_policies"`
	GCPOrgPolicies  map[string]interface{} `json:"gcp_organization_policies"`
}

func main() {
	flag.Parse()

	maxOneNonEmpty := func(ss ...string) bool {
		var n int
		for _, s := range ss {
			if s != "" {
				n++
			}
		}
		return n <= 1
	}

	if !maxOneNonEmpty(*inputDir, *inputPlan, *inputState) {
		log.Fatal("maximum one of --input_dir, --input_plan or --input_state must be specified")
	}

	if *inputConfig == "" {
		log.Fatal("--input_config must be set")
	}

	if *outputDir == "" {
		log.Fatal("--output_dir must be set")
	}

	if err := run(); err != nil {
		log.Fatalf("Failed to generate policies: %v", err)
	}
}

func run() error {
	var err error
	*inputConfig, err = pathutil.Expand(*inputConfig)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", *inputConfig, err)
	}

	*outputDir, err = pathutil.Expand(*outputDir)
	if err != nil {
		return fmt.Errorf("normalize path %q: %v", *outputDir, err)
	}

	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	c, err := loadConfig(*inputConfig)
	if err != nil {
		return fmt.Errorf("load config: %v", err)
	}

	if err := generateGCPOrgPolicies(tmpDir, c); err != nil {
		return fmt.Errorf("generate GCP organization policies: %v", err)
	}

	if err := generateForsetiPolicies(tmpDir, c); err != nil {
		return fmt.Errorf("generate Forseti policies: %v", err)
	}

	rn := &runner.Default{}
	var resources []terraform.Resource
	switch {
	case *inputDir != "":
		if resources, err = resourcesFromDir(rn, *inputDir); err != nil {
			return fmt.Errorf("read resources from configs directory: %v", err)

		}
	case *inputPlan != "":
		if resources, err = resourcesFromPlan(*inputPlan); err != nil {
			return fmt.Errorf("read resources from plan: %v", err)
		}
	case *inputState != "":
		if resources, err = resourcesFromState(*inputState); err != nil {
			return fmt.Errorf("read resources from state: %v", err)
		}
	default:
		log.Println("No input Terraform resources given")
	}

	log.Printf("Found %d resources from input Terraform resources", len(resources))

	// TODO: generate policies that rely on input config.

	if err := os.MkdirAll(*outputDir, 0755); err != nil {
		return fmt.Errorf("mkdir %q: %v", *outputDir, err)
	}

	fs, err := filepath.Glob(filepath.Join(tmpDir, "*"))
	if err != nil {
		return err
	}
	cp := exec.Command("cp", append([]string{"-a", "-t", *outputDir}, fs...)...)
	return rn.CmdRun(cp)
}

func loadConfig(path string) (*Config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config %q: %v", path, err)
	}
	c := new(Config)
	if err := yaml.Unmarshal(b, c); err != nil {
		return nil, fmt.Errorf("unmarshal config %q: %v", path, err)
	}
	if c.TemplateDir == "" {
		return nil, fmt.Errorf("`template_dir` is required")
	}
	if c.OrgID == "" {
		return nil, fmt.Errorf("`org_id` is required")
	}
	if !filepath.IsAbs(c.TemplateDir) {
		c.TemplateDir = filepath.Join(filepath.Dir(path), c.TemplateDir)
	}
	return c, nil
}

func generateForsetiPolicies(outputDir string, c *Config) error {
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

func generateGCPOrgPolicies(outputDir string, c *Config) error {
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

func resourcesFromDir(rn runner.Runner, path string) ([]terraform.Resource, error) {
	path, err := pathutil.Expand(path)
	if err != nil {
		return nil, fmt.Errorf("normalize path %q: %v", path, err)
	}

	tmpDir, err := ioutil.TempDir("", "")
	if err != nil {
		return nil, err
	}
	defer os.RemoveAll(tmpDir)

	tfCmd := func(args ...string) error {
		cmd := exec.Command("terraform", args...)
		cmd.Dir = tmpDir
		return rn.CmdRun(cmd)
	}
	tfCmdOutput := func(args ...string) ([]byte, error) {
		cmd := exec.Command("terraform", args...)
		cmd.Dir = tmpDir
		return rn.CmdOutput(cmd)
	}

	fs, err := filepath.Glob(filepath.Join(path, "*"))
	if err != nil {
		return nil, err
	}
	cp := exec.Command("cp", append([]string{"-a", "-t", tmpDir}, fs...)...)
	if err := rn.CmdRun(cp); err != nil {
		return nil, fmt.Errorf("copy configs to temp directory: %v", err)
	}

	if err := tfCmd("init"); err != nil {
		return nil, fmt.Errorf("terraform init: %v", err)
	}

	planPath := filepath.Join(tmpDir, "plan.tfplan")
	if err := tfCmd("plan", "-out", planPath); err != nil {
		return nil, fmt.Errorf("terraform plan: %v", err)
	}

	b, err := tfCmdOutput("show", "-json", planPath)
	if err != nil {
		return nil, fmt.Errorf("terraform show: %v", err)
	}

	resources, err := terraform.ReadPlanResources(b)
	if err != nil {
		return nil, fmt.Errorf("unmarshal json: %v", err)
	}
	return resources, nil
}

func resourcesFromPlan(path string) ([]terraform.Resource, error) {
	path, err := pathutil.Expand(path)
	if err != nil {
		return nil, fmt.Errorf("normalize path %q: %v", path, err)
	}
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read json: %v", err)
	}
	resources, err := terraform.ReadPlanResources(b)
	if err != nil {
		return nil, fmt.Errorf("unmarshal json: %v", err)
	}
	return resources, nil
}

func resourcesFromState(path string) ([]terraform.Resource, error) {
	path, err := pathutil.Expand(path)
	if err != nil {
		return nil, fmt.Errorf("normalize path %q: %v", path, err)
	}
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read json: %v", err)
	}
	resources, err := terraform.ReadStateResources(b)
	if err != nil {
		return nil, fmt.Errorf("unmarshal json: %v", err)
	}
	return resources, nil
}
