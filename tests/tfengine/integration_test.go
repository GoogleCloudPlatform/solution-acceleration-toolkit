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

// Prerequisites:
//  - The terraform binary must be available in $PATH.
//  - The environment variable RUN_INTEGRATION_TEST must be set to "true".
//  - The environment variables BILLING_ACCOUNT, FOLDER_ID and DOMAIN must be set.
//  - The runner (e.g. authenticated local user or service account) must have
//    the following roles:
//    - `roles/resourcemanager.projectCreator` on the folder
//    - `roles/resourcemanager.folderAdmin` on the folder
//    - `roles/compute.xpnAdmin` on the folder
//    - `roles/billing.user` on the billing account

package integration_test

import (
	"bytes"
	"fmt"
	"html/template"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
)

var dirsToDeploy = []string{
	"project_secrets",
	"project_networks",
	"project_apps",
	"project_data",
}

func TestFullDeployment(t *testing.T) {
	if os.Getenv("RUN_INTEGRATION_TEST") != "true" {
		t.SkipNow()
	}

	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		t.Fatalf("ioutil.TempDir = %v", err)
	}
	defer os.RemoveAll(tmp)

	confPath := filepath.Join(tmp, "config.hcl")
	writeConfig(t, confPath)
	if err := tfengine.Run(confPath, tmp, &tfengine.Options{Format: true, CacheDir: tmp}); err != nil {
		t.Fatalf("tfengine.Run = %v", err)
	}

	for _, dir := range dirsToDeploy {
		path := filepath.Join(tmp, dir)
		if err := tfengine.ConvertToLocalBackend(path); err != nil {
			t.Fatalf("ConvertToLocalBackend(%v): %v", path, err)
		}

		buildCmd := func(bin string, args ...string) *exec.Cmd {
			cmd := exec.Command(bin, args...)
			cmd.Dir = path
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			return cmd
		}

		init := buildCmd("terraform", "init")
		apply := buildCmd("terraform", "apply", "-auto-approve")
		destroy := buildCmd("terraform", "destroy", "-auto-approve")

		if err := init.Run(); err != nil {
			t.Fatalf("command %v in %q: %v", init.Args, path, err)
		}

		defer func() {
			if err := destroy.Run(); err != nil {
				t.Errorf("command %v in %q: %v", destroy.Args, path, err)
			}
		}()

		if err := apply.Run(); err != nil {
			t.Fatalf("command %v in %q: %v", apply.Args, path, err)
		}
	}
}

// confTmpl is a template for the input config file.
// CWD must be the path to the directory containing this integration test.
// For data values, see the schema in the team.hcl recipe.
var confTmpl = template.Must(template.New("").Parse(`
template "main" {
	recipe_path = "{{.CWD}}/../../examples/tfengine/modules/root.hcl"
	data = {
		recipes          = "../../templates/tfengine/recipes"
		folder_id       = "{{.FOLDER_ID}}"
		billing_account = "{{.BILLING_ACCOUNT}}"
		prefix          = "{{.PREFIX}}"
		state_bucket    = "placeholder" # Remote backend block will be removed by test.
		domain           = "{{.DOMAIN}}"
		env              = "p"
		default_location = "us-central1"
		default_zone     = "a"
		labels = {
			env = "prod"
		}
	}
}`))

func writeConfig(t *testing.T, path string) {
	t.Helper()
	data := buildData(t)

	var buf bytes.Buffer
	if err := confTmpl.Execute(&buf, data); err != nil {
		t.Fatalf("confTmpl.Execute(&buf, %v) = %v", data, err)
	}

	if err := ioutil.WriteFile(path, buf.Bytes(), 0644); err != nil {
		t.Fatalf("ioutil.WriteFile = %v", err)
	}
}

func buildData(t *testing.T) map[string]interface{} {
	t.Helper()

	_, callerPath, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller not ok")
	}
	prefix := fmt.Sprintf("dpt%v", time.Now().Unix())

	data := fromEnv(t, "BILLING_ACCOUNT", "FOLDER_ID", "DOMAIN")
	data["CWD"] = filepath.Dir(callerPath)
	data["PREFIX"] = prefix
	return data
}

func fromEnv(t *testing.T, keys ...string) map[string]interface{} {
	t.Helper()
	m := make(map[string]interface{})
	for _, key := range keys {
		v := os.Getenv(key)
		if v == "" {
			t.Fatalf("environment variable %q not set", key)
		}
		m[key] = v
	}
	return m
}
