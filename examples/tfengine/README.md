# Example Terraform Engine configs

This directory contains example Terraform Engine configs.

To start using the engine, replace an example with values for your
infrastructure.

- [./devops.hcl](./devops.hcl): This example is the minimal config needed to
  setup an infra-as-code Terraform environment for your infrastructure. This is
  a good starting point to understand the generated configs and CICD
  pipelines.

- [./org_foundation.hcl](./org_foundation.hcl): This example expands upon the
  [./devops.hcl](./devops.hcl) example to setup an org with additional security
  and compliance (e.g. long term and short term audit log retention, Forseti
  monitoring, etc). This should be a minimum done for an org. It can also be
  used to define the folder hierarchy of the org.

- [./folder_foundation.hcl](./folder_foundation.hcl): This example is similar to
  the [./org_foundation.hcl](./org_foundation.hcl) example except it sets
  everything on a folder instead of an org. This is useful if you want to test
  the generated configs in an isolated environment before promoting them to org
  level. This example assumes the root folder has already been created (for
  example by an org foundation config or other means).

- [./team.hcl](./team.hcl): This example sets up a sample team or application
  within a folder. This example focuses on projects and concrete resources to
  run services and assumes that core security, compliance and folder
  structure has already been seti up by other configs.

The [generated/](./generated) directory shows the output of each example.
