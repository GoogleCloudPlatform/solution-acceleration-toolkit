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
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

var license = []byte(`# Copyright 2020 Google LLC
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

`)

// AddLicense adds Google LLC Apache 2.0 license header to Terraform files in dir.
func AddLicense(dir string) error {

	fn := func(path string, info os.FileInfo, err error) error {
		if !isTerraformFile(path) {
			return nil
		}

		if err := writeLicense(path, info.Mode()); err != nil {
			return err
		}

		return nil
	}

	if err := filepath.Walk(dir, fn); err != nil {
		return err
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

	return ioutil.WriteFile(path, append(license, b...), fmode)
}

func isTerraformFile(name string) bool {
	name = strings.ToLower(filepath.Base(name))
	if name == "terragrunt.hcl" {
		return true
	}

	ext := filepath.Ext(name)
	return ext == ".tf" || ext == ".tfvars"
}
