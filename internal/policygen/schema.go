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

// Schema is the policygen input schema.
// TODO(https://github.com/golang/go/issues/35950): Move this to its own file.
var Schema = []byte(`
title = "Policy Generator Config Schema"
additionalProperties = false
required = ["template_dir"]

properties = {
  compatible_version = {
    description = "Minimum version of the binary required by this config."
    type        = "string"
  }

  template_dir = {
    description = <<EOF
      Absolute or relative path to the template directory. If relative, this path
      is relative to the directory where the config file lives.
    EOF
    type = "string"
  }

  forseti_policies = {
    description = "Key value pairs configure Forseti Policy Library constraints."
    type = "object"
    additionalProperties = false
    required = ["targets"]
    properties = {
      targets = {
        description = <<EOF
          List of targets to apply the policies, e.g. organizations/**,
          organizations/123/folders/456.
        EOF
        type = "array"
        items = {
          type = "string"
        }
      }

      allowed_policy_member_domains = {
        description = "The list of domains to allow users from, e.g. example.com"
        type = "array"
        items = {
          type = "string"
        }
      }
    }
  }
}
`)
