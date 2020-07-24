# Terraform Engine

Status: Early Access Program

The Terraform Engine is a tool to generate complete end-to-end Terraform
deployments for Google Cloud with security, compliance, and best practices baked
in.

It introduces the concept of "templates". Templates can be used to generate
multiple Terraform modules and configuration specific to your Google Cloud
organization and structure.

## Why

Users hosting sensitive data on Google Cloud typically complete
common and repetitive processes such as setting up devops (Remote state,
CICD), auditing, and monitoring. By using out-of-the-box end-to-end configs
that implement these steps for you, you can quickly set up a secure and compliant
environment and focus on the parts of the infrastructure that drive your
business.

This tool helps you follow:

- Google Cloud best practices through the use of modules from the
[Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit).

- [Terraform best practices](https://www.hashicorp.com/resources/evolving-infrastructure-terraform-opencredo)
    through the use of the
    [Terragrunt](https://terragrunt.gruntwork.io/) open source tool to define
    smaller and more modular configs.

Use our [example](../../examples/tfengine) configs to quickly get started.

## Prerequisites

1. Install the following dependencies and add them to your PATH:

    - [gcloud](https://cloud.google.com/sdk/gcloud)
    - [Terraform 0.12](https://www.terraform.io/)
    - [Terragrunt](https://terragrunt.gruntwork.io/)
    - [Go 1.14+](https://golang.org/dl/)

1. Familiarize yourself with the tools you'll use:

    - [Google Cloud](https://cloud.google.com/docs/overview)
    - [Terraform](https://www.terraform.io/intro/index.html)
    - [Terragrunt](https://blog.gruntwork.io/terragrunt-how-to-keep-your-terraform-code-dry-and-maintainable-f61ae06959d8)

    The infrastructure is deployed using Terraform, which is an industry
    standard for defining infrastructure-as-code. Terragrunt is used as a
    wrapper around Terraform to manage multiple Terraform deployments and reduce
    duplication.

1. Set up your
    [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)
    for Google Cloud resources.

1. [Create](https://support.google.com/a/answer/33343?hl=en) the following administrative
   [IAM](https://cloud.google.com/iam/docs/overview#concepts_related_identity) groups:

    - {PREFIX}-org-admins@{DOMAIN}: Members of this group get administrative access
        to the entire org. This group can be used in break-glass situations to
        give humans access to the org to make changes.

    - {PREFIX}-devops-owners@{DOMAIN}: Members of this group get owners access to
        the devops project to make changes to the CICD project or to make changes
        to the Terraform state.

    - {PREFIX}-auditors@{DOMAIN}: Members of this group get security reviewer
        (metadata viewer) access to the entire org and viewer access to
        the audit logs BigQuery and Cloud Storage resources.

    - {PREFIX}-cicd-viewers@{DOMAIN}: Memberso of this group can view CICD
        results such as presubmit speculative plan and postsubmit deployment results.

    For example, with sample prefix "gcp" and domain "example.com", the admin group
    "gcp-org-admins@example.com" would be created.

    WARNING: The best practice is to always deploy changes using CICD.
    The privileged groups should remain empty and only have humans added for
    emergency situations or when investigation is required. This does not apply
    to view-only groups such as approvers.

1. The running user will need to be a super admin or have the following roles:

    - `roles/resourcemanager.organizationAdmin` on the org
    - `roles/resourcemanager.projectCreator` on the org
    - `roles/billing.user` on the billing account

## Defining Architecture

Plan out your org architecture and map them to engine configs.
Our configs can help you setup a wide variety of architectures that suit your
needs.

As a rule of thumb, we recommend having one org config that sets up core
security and compliance infrastructure such as auditing, monitoring and org
policies. It should define a devops project to manage Terraform
state and a CICD pipeline. You can also use this config to define the org's
folder hierarchy. We recommend creating a folder for each team and major
application in the org.

To define projects for a team or application, we recommend having a separate
config. These configs should set the root parent folder to be one of the
folders setup by the org config. Each config should define a devops project
to manage Terraform state and a CICD pipeline.

You may wish to replicate the configs across multiple environments (dev,
staging, etc).

All configs and the generated Terraform code should be checked into version
control. You can use a separate repo for each CICD pipeline. Note if using
GitHub you can share a single repo but with different paths within the repo.
For Cloud Source Repository, you must use a repo within each individual
devops project.

## Usage

The engine takes a path to an input config and a path to output the generated
Terraform configs. For details on fields for the input schema, see the
[schema](../../internal/tfengine/schema.go). After the output has been generated,
there is no longer a dependency on the engine and the user can directly use
the `terraform` and `terragrunt` binaries to deploy the infrastructure.

1. Download the latest
   [tfengine binary](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases)
   or build one yourself:

    ```shell
    git clone https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite
    cd healthcare-data-protection-suite
    go install ./cmd/tfengine
    ```

1. Replace the values in a suitable
   [example](../../examples/tfengine) with values for your infrastructure.

   Project and Bucket names are globally unique and must be changed from defaults.
   You will get an error if you have chosen a name that is already taken.

   TIP: Prefer to remotely fetch templates from a release which can be more
   stable than using the HEAD templates.

   ```hcl
   template "devops" {
     recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/devops.hcl?ref=templates-v0.1.0"
     data = {
       ...
     }
   }
   ```

1. To set up helper environment vars, run the following commands:

    ```shell
    CONFIG_PATH=examples/tfengine/org_foundation.hcl
    OUTPUT_PATH=/tmp/engine
    ```

1. Run the engine to generate your Terraform configs:

    ```shell
    tfengine --config_path=$CONFIG_PATH --output_path=$OUTPUT_PATH
    ```

1. To run the one-time bootstrap to set up the devops project to host the Terraform
   state, run the following commands:

   ```shell
    cd $OUTPUT_PATH/bootstrap
    terraform init
    terraform plan
    terraform apply
    ```

1. (Optional) To deploy Continuous Integration (CI) and Continuous
   Deployment (CD) resources, follow the instructions in
   components/cicd/README.md in this directory or $OUTPUT_PATH/cicd/README.md in
   the generated Terraform configs directory.

   Your devops project and CICD pipelines are ready. The
   following changes should be made as Pull Requests (PRs) and go though code
   reviews. After approval is granted and CI tests pass, merge the PR. The CD job
   automatically deploys the change to your Google Cloud infra.

1. Deploy org infrastructure and other resources by sending a PR for
   local changes to the config repo.

1. (Optional) Deploy secrets if set and set the values for manual ones in the GCP
    console.

1. Follow the instructions of all commented out blocks starting with
   `TODO(user)` in the config to deploy the changes. Remove the comment once done.

## Tips

- Before running `terragrunt apply-all`, always run `terragrunt plan-all` and
  carefully review the output. The CICD creates a trigger to generate the
  plan. Look for the values of the known fields to ensure they are what you
  expect. You may see some values with the word "mock" in them. These values
  are coming from other deployments and will be filled with the real value
  after Terragrunt runs the dependent deployment.

- If you plan on using the engine again, do not manually modify any generated
  file as it will be overwritten the next time the engine runs. Instead,
  prefer to change the input config, recipe, or component for the generated
  files and add new resources under new deployments that are not generated by
  the engine.

- Always back up any engine configs as well as the generated Terraform configs
  and any modifications to the Terraform configs to version control.

- Any component file with the extension `.tmpl` will have it removed when
  generated.
