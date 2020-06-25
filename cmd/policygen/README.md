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
STATE_PATH=/path/to/your/tfstate
OUTPUT_PATH=/tmp/policygen

# Step 3: Install the policygen
go install ./cmd/policygen

# Step 4: Generate policies. Edit config with values of your infra.
# nano $CONFIG_PATH
policygen --config_path=$CONFIG_PATH --state_path=$STATE_PATH --output_path=$OUTPUT_PATH
```

`--state_path` supports a single local file, a local directory or a Google Cloud
Storage bucket (indicated by `gs://` prefix).

* If the path is a single local file, it loads Terraform states from it.
* If the path is a local directory, it walks the directory recursively and
    loads Terraform states from each `.tfstate` file.
* If the path is a Cloud Storage bucket, it walks the bucket recursively and
    loads Terraform states from each `.tfstate` file. It only reads the bucket
    name from the `--state_path` and ignores the file/dir, if specified. All
    `.tfstate` file from the bucket will be read. The program uses
    [Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default)
    to authenticate with GCP. Make sure you have at least
    `roles/storage.objectViewer` permission on the bucket.

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
    Forseti Terraform module version >= 5.2.1 is needed.

* To use Policy Library Constraints with **Terraform Validator**, follow
    [How to use Terraform Validator](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator).

The `target` value under the `match` block in the generated policies based on
Terraform state might need to be adjusted manually to include the ancestor paths
in the `composite_root_resources` field set in your Forseti Terraform module or
the `--ancestry` path set when you run Terraform Validator.

For example, a Terraform state based `allow_iam_roles.yaml` policy might look
like the following, which is to restrict allowed IAM roles in project with
project number 789.

```yaml
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPIAMAllowBanRolesConstraintV1
metadata:
  name: iam_allow_roles
spec:
  severity: high
  match:
    target:
    - "project/789"
  parameters:
    mode: "allow"
    roles:
    - roles/cloudsql.client
    - roles/logging.logWriter
    - roles/storage.objectCreator
```

Assume project 789 is located under folder 456 in organization 123. If the
`composite_root_resources` in the Forseti Terraform module is configured at
project level, e.g. `projects/789` or `projects/*`, then the policy is good to
go. However, if the `composite_root_resources` is set to higher level ancestors,
e.g. `organizations/123/*` or `folders/456/*`, then your `target` field should
be modified to include the ancestors in the `target` path as well. In this
example, your `target` field should be modified to be
`organizations/123/folders/456/projects/789` and `folders/456/projects/789`,
respectively.
