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

// Package licenseutil provides utility functions around licenses.
package licenseutil

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

const licenseString = `# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

`

// AddLicense adds Google LLC Apache 2.0 license header to Terraform files in dir.
func AddLicense(dir string) error {
	fs, err := ioutil.ReadDir(dir)
	if err != nil {
		return fmt.Errorf("read dir %q: %v", dir, err)
	}
	if len(fs) == 0 {
		return fmt.Errorf("found no files in %q to write", dir)
	}

	for _, f := range fs {
		out := filepath.Join(dir, f.Name())

		if f.IsDir() {
			if err := AddLicense(out); err != nil {
				return err
			}
			continue
		}

		if !isTerraformFile(out) {
			continue
		}

		if err := writeLicense(out, f.Mode()); err != nil {
			return nil
		}
	}

	return nil
}

func writeLicense(path string, fmode os.FileMode) error {
	b, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}

	if bytes.Contains(b, []byte("Copyright 2020 Google LLC")) {
		return nil
	}

	b = append([]byte(licenseString), b...)
	return ioutil.WriteFile(path, b, fmode)
}

func isTerraformFile(name string) bool {
	name = strings.ToLower(filepath.Base(name))
	if name == "terragrunt.hcl" {
		return true
	}

	ext := name
	if v := filepath.Ext(name); v != "" {
		ext = strings.ToLower(v)
	}

	return ext == ".tf" || ext == ".tfvars"
}
