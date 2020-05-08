# Continuous Integration (CI) and Continuous Deployment (CD) component

This directory contains the Terraform configs for the Continuous Integration (CI)
and Continuous Deployment (CD) component.

* The `manual/` directory contains the Terraform resources that need to be
  deplopyed manually to provision the initial CI/CD resources.

* The `auto/` directory contains the Terraform resouces for CI/CD purposes
  that are also managed by CI/CD itself. Note that, the resources to put here
  should be carefully reviewed as the devops project is sensitive and most
  changes should done by a human operator to avoid CI/CD misconfigures itself.
