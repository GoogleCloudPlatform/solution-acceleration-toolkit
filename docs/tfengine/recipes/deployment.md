# Terraform Deployment Recipe

## Properties

### enable_terragrunt

Whether to convert to a Terragrunt deployment.
Adds a terragrunt.hcl file in the deployment.

Type: boolean

### state_bucket

State bucket to use for GCS backend. Does nothing if 'enable_terragrunt' is true.

Type: string

### state_path_prefix

Object path prefix for GCS backend. Does nothing if 'enable_terragrunt' is true.

Type: string

### terraform_addons

Extra addons to set in the deployment.

Type: object

### terraform_addons.deps

Additional dependencies on other deployments.

Type: array(object)

### terraform_addons.deps.mock_outputs

Mock outputs for the deployment to add.

Type: object

### terraform_addons.deps.name

Name of dependency.

Type: string

### terraform_addons.deps.path

Path to deployment.

Type: string

### terraform_addons.inputs

Additional inputs to be set in terraform.tfvars

Type: object

### terraform_addons.outputs

Additional outputs to set in outputs.tf.

Type: array(object)

### terraform_addons.outputs.name

Name of output.

Type: string

### terraform_addons.outputs.value

Value of output.

Type: string

### terraform_addons.raw_config

Raw text to insert in the Terraform main.tf file.
Can be used to add arbitrary blocks or resources that the engine does not support.

Type: string

### terraform_addons.vars

Additional vars to set in the deployment in variables.tf.

Type: array(object)

### terraform_addons.vars.default

Default value of variable.

### terraform_addons.vars.name

Name of the variable.

Type: string

### terraform_addons.vars.terragrunt_input

Input value to set in terragrunt.hcl for this var.

### terraform_addons.vars.type

Type of variable.

Type: string

### terraform_addons.vars.value

Value of variable to set in terraform.tfvars.
