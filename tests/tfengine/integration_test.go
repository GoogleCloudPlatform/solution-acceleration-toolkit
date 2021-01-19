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

package integration_test

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"
	"text/template"
	"time"

	"github.com/GoogleCloudPlatform/healthcare-data-protection-suite/internal/tfengine"
)

var (
	dirs = []string{"project_secrets"}

	confTmpl = template.Must(template.New("").Parse(`
template "main" {
	recipe_path = "{{.CWD}}/../../examples/tfengine/templates/team.hcl"
	data = {
		state_bucket    = "placeholder" # Remote backend block will be removed by test.
		prefix          = "{{.PREFIX}}"
		billing_account = "{{.BILLING_ACCOUNT}}"
		parent_id       = "{{.FOLDER_ID}}"
	}
}
`))
)

func TestFullDeployment(t *testing.T) {
	if os.Getenv("RUN_INTEGRATION_TEST") == "" {
		t.SkipNow()
	}

	tmp, err := ioutil.TempDir("", "")
	if err != nil {
		t.Fatalf("ioutil.TempDir = %v", err)
	}
	defer os.RemoveAll(tmp)

	data := buildData(t)

	var buf bytes.Buffer
	if err := confTmpl.Execute(&buf, data); err != nil {
		t.Fatalf("confTmpl.Execute(&buf, %v) = %v", data, err)
	}

	confPath := filepath.Join(tmp, "config.hcl")
	b := buf.Bytes()
	t.Logf("config file:\n%v", string(b))
	if err := ioutil.WriteFile(confPath, b, 0644); err != nil {
		t.Fatalf("ioutil.WriteFile = %v", err)
	}

	if err := tfengine.Run(confPath, tmp, &tfengine.Options{Format: true, CacheDir: tmp}); err != nil {
		t.Fatalf("tfengine.Run = %v", err)
	}

	for _, dir := range dirs {
		path := filepath.Join(tmp, dir)
		if err := tfengine.ConvertToLocalBackend(path); err != nil {
			t.Fatalf("ConvertToLocalBackend(%v): %v", path, err)
		}

		setupCmd := func(cmd *exec.Cmd) {
			cmd.Dir = path
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
		}

		init := exec.Command("terraform", "init")
		setupCmd(init)

		apply := exec.Command("terraform", "apply", "-auto-approve")
		setupCmd(apply)

		destroy := exec.Command("terraform", "destroy", "-auto-approve")
		setupCmd(destroy)

		if err := init.Run(); err != nil {
			t.Fatalf("command %v in %q: %v", init.Args, path, err)
		}

		err := apply.Run()
		defer func() {
			if err := destroy.Run(); err != nil {
				t.Errorf("command %v in %q: %v", destroy.Args, path, err)
			}
		}()
		if err != nil {
			t.Fatalf("command %v in %q: %v", apply.Args, path, err)
		}
	}
}

func buildData(t *testing.T) map[string]interface{} {
	t.Helper()

	_, callerPath, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller not ok")
	}
	prefix := fmt.Sprintf("dpstest-%v", time.Now().Unix())

	data := fromEnv(t, "BILLING_ACCOUNT", "FOLDER_ID")
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
