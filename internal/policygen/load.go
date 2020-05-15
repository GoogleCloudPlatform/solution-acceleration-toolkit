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
	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/terraform"
	"github.com/ghodss/yaml"
)

func loadConfig(path string) (*config, error) {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read config %q: %v", path, err)
	}
	c := new(config)
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

func loadResources(rn runner.Runner, inputDir, inputPlan, inputState string) ([]terraform.Resource, error) {
	var resources []terraform.Resource
	var err error
	switch {
	case inputDir != "":
		if resources, err = resourcesFromDir(rn, inputDir); err != nil {
			return nil, fmt.Errorf("load resources from configs directory: %v", err)
		}
	case inputPlan != "":
		if resources, err = resourcesFromPlan(inputPlan); err != nil {
			return nil, fmt.Errorf("load resources from plan: %v", err)
		}
	case inputState != "":
		if resources, err = resourcesFromState(inputState); err != nil {
			return nil, fmt.Errorf("load resources from state: %v", err)
		}
	default:
		log.Println("No Terraform input given, only generating Terraform-agnostic security policies")
	}
	return resources, nil
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
