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

package tfengine

// Schema is the Terraform engine input schema.
// TODO(https://github.com/golang/go/issues/35950): Move this to its own file.
const Schema = `
title = "Terraform Engine Config Schema"

additionalProperties = false

properties = {
  version = {
    description = "Optional constraint on the binary version required for this config."
    type        = "string"
  }

  data = {
    description = <<EOF
      Global set of key-value pairs to pass to all templates.
      It will be merged with data set in the templates.
    EOF
    type = "object"
  }

  template = {
    description = <<EOF
      Templates the engine will parse and fill in with values from data.

      Templates use the [Go templating engine](https://golang.org/pkg/text/template/).

      Template maintainers can use several
      [helper template funcs](../../template/funcmap.go).
    EOF
    type = "array"
    items = {
      type                 = "object"
      additionalProperties = false
      properties = {
        name = {
          description = "Name of the template."
          type        = "string"
        }

        recipe_path = {
          description = "Path to a recipe YAML config. Mutually exclusive with 'component_path'."
          type        =  "string"
        }

        output_path = {
          description = <<EOF
            Relative path for this template to write its contents.
            This value will be joined with the value passed in by the flag at
            --output_path.
          EOF
          type = "string"
        }

        data = {
          description = "Key value pairs passed to this template."
          type        = "object"
        }

        # ----------------------------------------------------------------------
        # NOTE: The fields below should typically be set by recipe maintainers and not end users.
        # ----------------------------------------------------------------------

        component_path = {
          description = "Path to a component directory. Mutually exclusive with 'recipe_path'."
          type        = "string"
        }

        flatten = {
          description = <<EOF
            Keys to flatten within an object or list of objects.
            Any resulting key value pairs will be merged into data.
            This is not recursive.

            Example:
              A foundation recipe may expect audit information to be in a field 'AUDIT'.
              Thus a user will likely write 'AUDIT: { PROJECT_ID: "foo"}' in their config.
              However, the audit template itself will look for the field 'PROJECT_ID'.
              Thus, the audit template should flatten the 'AUDIT' key.
          EOF
          type = "array"
          items = {
            type = "object"
            required = ["key"]
            properties = {
              key = {
                description = "Name of key in data to flatten."
                type        = "string"
              }
              index = {
                description = "If set, assume value is a list and the index is being flattened."
                type        = "integer"
              }
            }
          }
        }
      }
    }
  }

  schema = {
    description = "Schema the data for this template must adhere to. Typically only set in recipes."
    type        = "object"
  }
}
`
