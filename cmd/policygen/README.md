# Policy Generator

Status: Early Access Program

A security policy generator which generates policies for two purposes:

1. Typical policies enforced in a HIPAA aligned GCP environment.
1. Policies based on Terraform states to monitor GCP changes that are not
    deployed by Terraform.

Currently supported Policy Libraries:

* [Policy Library](https://github.com/forseti-security/policy-library) as YAML
    files.
* [Google Cloud Platform Organization Policy Constraints](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
    as Terraform configs.

## Prerequisites

1. Install the following dependencies and add them to your PATH:

    * [gcloud](https://cloud.google.com/sdk/gcloud)
    * [Terraform 0.12](https://www.terraform.io/)
    * [Go 1.14+](https://golang.org/dl/)

1. Get familiar with
    [GCP Organization Policy Constraints](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
    and
    [Policy Library Constraints](https://github.com/forseti-security/policy-library).

## Usage

### Generate policies

```shell
# Step 1: Clone repo
git clone https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite
cd healthcare-data-protection-suite

# Step 2: Setup helper env vars
CONFIG_PATH=examples/policygen/config.yaml
STATE_PATH=/path/to/your/tfstate/file
OUTPUT_PATH=/tmp/policygen

# Step 3: Install the policygen
go install ./cmd/policygen

# Step 4: Generate policies. Edit config with values of your infra.
# nano $CONFIG_PATH
policygen --config_path=$CONFIG_PATH --state_path=$STATE_PATH --output_path=$OUTPUT_PATH
```

### Use policies

#### GCP Organization Policy Constraints

To deploy GCP Organization Policy Constraints, execute the following commands:

```shell
cd $OUTPUT_PATH/gcp_org_policies
terraform init
terraform plan
terraform apply
```

#### Policy Library Constraints

* To use Policy Library Constraints with **Forseti**, follow
    [How to use Forseti Config Validator](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-forseti-config-validator).

    The `target` values under `match` block in the auto-generated policies might
    need to be adjusted manually to match the `composite_root_resources` field
    set in your Forseti Terraform module.

* To use Policy Library Constraints with **Terraform Validator**, follow
    [How to use Terraform Validator](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator).

    The `target` values under `match` block in the auto-generated policies might
    need to be adjusted manually to match the `--ancestry` path when you run
    Terraform Validator.
