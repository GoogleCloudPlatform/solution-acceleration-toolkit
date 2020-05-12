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

// TODO(https://github.com/golang/go/issues/35950): Move this to its own file.
const schema = `
title: Terraform Engine Config Schema

properties:
  data:
    description: |
      Global set of key-value pairs to pass to all templates.
      It will be merged with data set in the templates.
    type: object

  templates:
    description: |
      Templates the engine will parse and fill in with values from data.
      Templates use the Go templating engine: https://golang.org/pkg/text/template/
      Helper template funcs are also defined in ../template/funcmap.go.
    type: array
    items:
      type: object
      additionalProperties: false
      properties:
        name:
          description: Name of the template. Can be referred to by 'output_ref'.
          type: string

        recipe_path:
          description: Path to a recipe YAML config. Mutually exclusive with 'component_path'.
          type: string

        output_ref:
          description: |
            OutputRef allows this template write its contents to the same dir as another template.

            Example:
            If output_ref is set to 'foo.bar' then this will look for sibling template 'foo' (defined in this list) and a child template inside 'foo' called 'bar'.
          type: string

        data:
          descripton: Key value pairs passed to this template.

        # ----------------------------------------------------------------------
        # NOTE: The fields below should typically be set by recipe maintainers and not end users.
        # ----------------------------------------------------------------------

        component_path:
          description: Path to a component directory. Mutually exclusive with 'recipe_path'.
          type: string

        output_path:
          description: |
            OutputPath allows this template to write its contents to a specific directory.
            The final output path of this template is a join of the following:
              - The base output path defined by the --output_path flag.
              - The output ref to another template, if set.
              - The output path defined by this field.

            Example:
              - Flag --output_path = /tmp/engine
              - Field 'output_ref' set to a template which set output_path to './foo'
              - This field is set to './bar'
              - The final output path for this template is: '/tmp/engine/foo/bar'.
          type: string

        flatten:
          description: |
            Keys to flatten within an object or list of objects.
            Any resulting key value pairs will be merged into data.

            Example:
              A foundation recipe may expect audit information to be in a field 'AUDIT'.
              Thus a user will likely write 'AUDIT: { PROJECT_ID: "foo"}' in their config.
              However, the audit template itself will look for the field 'PROJECT_ID'.
              Thus, the audit template should  flatten the 'AUDIT' key.
          type: array
          items:
            type: object
            required:
            - key
            properties:
              key:
                description: Name of key in data to flatten.
                type: string

              index:
                description: If set, assume value is a list and the index is being flattened.
                type: integer
`
