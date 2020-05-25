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
          description: Name of the template.
          type: string

        recipe_path:
          description: Path to a recipe YAML config. Mutually exclusive with 'component_path'.
          type: string

        output_path:
          description: |
            Relative path for this template to write its contents.
            This value will be joined with the value passed in by the flag at
            --output_path.
          type: string

        data:
          descripton: Key value pairs passed to this template.
          type: object
          properties:
            # TODO(xingao): Move these to a per-recipe schema.
            parent_type:
              description: |
                Type of parent GCP resource: can be "organization" or "folder".
              type: string
              pattern: ^organization|folder$

            parent_id:
              description: |
                ID of parent GCP resource: can be the organization ID or
                folder ID according to parent_type.
              type: string
              pattern: ^[0-9]{8,25}$

            org_policies:
              # TODO(xingao): Get the full org policies schema from policygen schema.
              description: |
                Key value pairs passed to GCP Organization Policy constraint templates.
              type: object
              properties:
                parent_type:
                  description: |
                    Type of parent GCP resource to apply the policy: can be one of "organization",
                    "folder", or "project".
                  type: string
                  pattern: ^organization|folder|project$

        # ----------------------------------------------------------------------
        # NOTE: The fields below should typically be set by recipe maintainers and not end users.
        # ----------------------------------------------------------------------

        component_path:
          description: Path to a component directory. Mutually exclusive with 'recipe_path'.
          type: string

        flatten:
          description: |
            Keys to flatten within an object or list of objects.
            Any resulting key value pairs will be merged into data.
            This is not recursive.

            Example:
              A foundation recipe may expect audit information to be in a field 'AUDIT'.
              Thus a user will likely write 'AUDIT: { PROJECT_ID: "foo"}' in their config.
              However, the audit template itself will look for the field 'PROJECT_ID'.
              Thus, the audit template should flatten the 'AUDIT' key.
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
