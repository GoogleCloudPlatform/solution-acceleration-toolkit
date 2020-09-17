# Terraform Engine Config Schema

<!-- These files are auto generated -->

## Properties

### data

Global set of key-value pairs to pass to all templates.
It will be merged with data set in the templates.

Type: object

### schema

Schema the data for this template must adhere to. Typically only set in recipes.

Type: object

### template

Templates the engine will parse and fill in with values from data.

Templates use the [Go templating engine](https://golang.org/pkg/text/template/).

Template maintainers can use several
[helper template funcs](../../template/funcmap.go).

Type: array(object)

### template.component_path

Path to a component directory. Mutually exclusive with 'recipe_path'.

Type: string

### template.data

Key value pairs passed to this template.

Type: object

### template.flatten

Keys to flatten within an object or list of objects.
Any resulting key value pairs will be merged into data.
This is not recursive.

Example:
A foundation recipe may expect audit information to be in a field 'AUDIT'.
Thus a user will likely write 'AUDIT: { PROJECT_ID: "foo"}' in their config.
However, the audit template itself will look for the field 'PROJECT_ID'.
Thus, the audit template should flatten the 'AUDIT' key.

Type: array(object)

### template.flatten.index

If set, assume value is a list and the index is being flattened.

Type: integer

### template.flatten.key

Name of key in data to flatten.

Type: string

### template.name

Name of the template.

Type: string

### template.output_path

Relative path for this template to write its contents.
This value will be joined with the value passed in by the flag at
--output_path.

Type: string

### template.recipe_path

Path to a recipe YAML config. Mutually exclusive with 'component_path'.

Type: string

### version

Optional constraint on the binary version required for this config.
See [syntax](https://www.terraform.io/docs/configuration/version-constraints.html).

Type: string
