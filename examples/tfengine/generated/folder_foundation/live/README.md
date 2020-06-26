# Root

This directory defines the entire architecture in Terraform.

It should initially be deployed by running `terragrunt apply-all` after
`../bootstrap` has been deployed.

Afterwards, subsets can be independently deployed using `terragrunt apply`.

If you configured and deployed [cicd/](../cicd), then configs under this
directory are deployed by CICD pipelines.
