# Continuous Integration (CI) and Continuous Deployment (CD) component

This directory contains the Terraform configs for the Continuous Integration (CI)
and Continuous Deployment (CD) component.

* The `manual/` directory contains the Terraform resources that need to be
  deployed manually to provision the initial CI/CD resources.

* The `auto/` directory contains the Terraform resouces for CI/CD purposes
  that are also managed by CI/CD itself.

  Sensitive resources in the devops project such as

  * Terraform state bucket
  * IAM bindings
  * Cloud Build Triggers

   should not be put here to let CI/CD manage them, which could lead to
   potential misconfiguration of itself. Those resources should be included
   in the `main.tf` in `cicd/` directory at root and deployed manually by
   an human owner of the devops project.
