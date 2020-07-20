
# Terraform Deployment Recipe.

## Properties

### enable_terragrunt

Whether to convert to a Terragrunt deployment. Adds a terragrunt.hcl file in the deployment.



### state_bucket

State bucket to use for GCS backend. Does nothing if 'enable_terragrunt' is true.



### state_path_prefix

Object path prefix for GCS backend. Does nothing if 'enable_terragrunt' is true.



### terraform_addons

Extra addons to set in the deployment.



