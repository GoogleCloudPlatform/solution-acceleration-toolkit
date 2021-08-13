# Terraform Engine Config Schema

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| data | Global set of key-value pairs to pass to all templates. It will be merged with data set in the templates. | object | false | - | - |
| schema | Schema the data for this template must adhere to. Typically only set in recipes. | object | false | - | - |
| template | Templates the engine will parse and fill in with values from data.<br><br>Templates use the [Go templating engine](https://golang.org/pkg/text/template/).<br><br>Template maintainers can use several [helper template funcs](../../template/funcmap.go). | array(object) | false | - | - |
| template.component_path | Path to a component directory. Mutually exclusive with 'recipe_path'. | string | false | - | - |
| template.data | Key value pairs passed to this template. | object | false | - | - |
| template.flatten | Keys to flatten within an object or list of objects. Any resulting key value pairs will be merged into data. This is not recursive.<br><br>Example: A foundation recipe may expect audit information to be in a field 'AUDIT'. Thus a user will likely write 'AUDIT: { PROJECT_ID: "foo"}' in their config. However, the audit template itself will look for the field 'PROJECT_ID'. Thus, the audit template should flatten the 'AUDIT' key. | array(object) | false | - | - |
| template.flatten.index | If set, assume value is a list and the index is being flattened. | integer | false | - | - |
| template.flatten.key | Name of key in data to flatten. | string | true | - | - |
| template.name | Name of the template. | string | false | - | - |
| template.output_path | Relative path for this template to write its contents. This value will be joined with the value passed in by the flag at --output_path. | string | false | - | - |
| template.passthrough | Keys to pass directly to a child template data. This is not recursive.<br><br>Example: The deployment recipe expects "terraform_addons" to be passed to 	      it directly, so the project recipe uses this key to do so. | array(string) | false | - | - |
| template.recipe_path | Path to a recipe YAML config. Mutually exclusive with 'component_path'. | string | false | - | - |
| version | Optional constraint on the binary version required for this config. See [syntax](https://www.terraform.io/docs/configuration/version-constraints.html). | string | false | - | - |
