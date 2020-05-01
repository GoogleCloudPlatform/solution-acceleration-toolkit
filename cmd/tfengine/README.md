# Terraform Engine

Status: Early Access Program

Terraform Engine is a framework to jump start your organization onto GCP. It is
a Terraform module generator that puts together Terraform resources and modules
into deployments complete with values for your infrastructure.

## Why

Users hosting any type of sensitive data on GCP typically need to go through a
few common and repetitive processes such as setting up devops, auditing and
monitoring. By using our out of the box end-to-end configs that implement these
steps for you, you can quickly setup a secure and compliant environment and
focus on the parts of the infrastructure that drive your business.

This tool will help you follow Terraform
[best practices](https://www.hashicorp.com/resources/evolving-infrastructure-terraform-opencredo),
by using the popular open source tool
[Terragrunt](https://terragrunt.gruntwork.io/) to define smaller modular configs
rather than monolithic modules that quickly get out of hand or need a custom
pipeline to manage.

Our templates use Google's best practice modules from the
[Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit).

Use our [sample](./samples) configs to quickly get started.

## Prerequisites

1. Install the following dependencies and add them to your PATH:

    - [gcloud](https://cloud.google.com/sdk/gcloud)
    - [Terraform 0.12](https://www.terraform.io/)
    - [Terragrunt](https://terragrunt.gruntwork.io/)
    - [Go 1.14+](https://golang.org/dl/)

1. Get familiar with [GCP](https://cloud.google.com/docs/overview),
    [Terraform](https://www.terraform.io/intro/index.html) and
    [Terragrunt](https://blog.gruntwork.io/terragrunt-how-to-keep-your-terraform-code-dry-and-maintainable-f61ae06959d8).

    The infrastructure is deployed using Terraform, which is an industry
    standard for defining infrastructure-as-code. Terragrunt is used as a
    wrapper around Terraform to manage multiple Terraform deployments and reduce
    duplication.

1. Setup your
    [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)
    for GCP resources and [G Suite Domain](https://gsuite.google.com/) for
    groups.

1. [Create administrative groups](https://support.google.com/a/answer/33343?hl=en)
    in the G Suite Domain:

    - {PREFIX}-org-admins@{DOMAIN}: This group will get administrative access
        to the entire org. This group can be used in break-glass situations to
        give humans access to the org to make changes.

    - {PREFIX}-devops-owners@{DOMAIN}: This group will get owners access to
        the devops project to make changes to the CICD project or make changes
        to the Terraform state.

    - {PREFIX}-auditors@{DOMAIN}: This group will get security reviewer
        (metadata viewer) access to the entire org, as well as viewer access to
        the audit logs BigQuery and Cloud Storage resources.

    - {PREFIX}-approvers@{DOMAIN}: This group will get access to view
        Terraform plans and should approve PRs in the GitHub repo.

    For example, with sample prefix "gcp" and domain "example.com" the group
    "gcp-org-admins@example.com" should be created.

    WARNING: It is always recommended to use CICD to deploy the changes instead.
    The privileged groups should remain empty and only have humans added for
    emergency situations or when investigation is required. This does not apply
    to view only groups such as approvers.

1. The running user will need to be a super admin or have the following roles:

    - `roles/resourcemanager.organizationAdmin` on the org
    - `roles/resourcemanager.projectCreator` on the org
    - `roles/billing.user` on the billing account

## Usage

The engine takes a path to an input config and a path to output the generated
Terraform configs. After the output has been generated, there is no dependency
on the engine any longer, and the user can directly use the `terraform` and
`terragrunt` binaries to deploy the infrastructure.

Replace the values in the [example](../../examples/tfengine/simple.yaml) with values
for your infrastructure, then run the following commands:

```shell
# Step 1: Clone repo
git clone https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite
cd healthcare-data-protection-suite

# Step 2: Setup helper env vars
CONFIG_PATH=examples/tfengine/simple.yaml
OUTPUT_PATH=/tmp/engine

# Step 3: Install the engine
go install ./cmd/tfengine

# Step 4: Generate Terraform configs. Edit config with values of your infra.
nano $CONFIG_PATH
tfengine --config_path=$CONFIG_PATH --output_path=$OUTPUT_PATH

# Step 5: Run one time bootstrap to setup devops project to host Terraform state.
cd $OUTPUT_PATH/bootstrap
terraform init
terraform plan
terraform apply

# Step 6 (Optional): Deploy Continuous Integration (CI) and Continuous
# Deployment (CD) resources by following the instructions in
# components/cicd/README.md in this directory or $OUTPUT_PATH/cicd/README.md in
# the generated Terraform configs directory.

# After the above is done. Your devops project and CICD pipelines are ready, and
# following changes should be made as Pull Requests (PRs) and go though code
# reviews. Once approval is granted and CI tests pass, merge the PR. The CD job
# will automatically deploy the change to your GCP infra.

# Step 7: Deploy org infrastructure and other resources by sending a PR for
# local changes to the config repo.

# Step 8: If a `DISABLED` block is present in the config, follow the steps for
# all fields within the block and deploy the changes. Remove the `DISABLED`
# block from the config once done.

# Step 9 (Optional): Modify and/or add deployments as needed...
cd $OUTPUT_PATH/org/.../example-deployment
# And then send the change as a PR.
```

## Tips

- Before running `terragrunt apply-all` always run `terragrunt plan-all` and
  carefully review the output. The CICD will create a trigger to generate the
  plan. Look for the values of the known fields to ensure they are what you
  expect. You may see some values with the word "mock" in them. These values
  are coming from other deployments and will be filled with the real value
  once Terragrunt runs the dependent deployment.

- If you plan on using the engine again, do not manually modify any generated
  file as it will be overwritten the next time the engine runs. Instead,
  prefer to change the input config, recipe or component for the generated
  files and add new resources under new deployments that are not generated by
  the engine.

- Always backup any engine configs as well as the generated Terraform configs
  and any modifications to the Terraform configs to version control.
