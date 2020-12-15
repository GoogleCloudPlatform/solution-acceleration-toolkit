# Terraform Engine

The Terraform Engine is a tool to generate complete end-to-end Terraform
deployments for Google Cloud with security, compliance, and best practices baked
in.

Use our [example](../../examples/tfengine) configs to quickly get started.

## Terminology

The Terraform engine introduces the concept of "templates". Templates can be
used to generate
[Terraform root modules](https://www.terraform.io/docs/glossary.html#root-module)
specific to your Google Cloud organization and structure.

Users typically pick from a set of [recipes](../../templates/tfengine/recipes)
which implement a template for one core piece of GCP infrastructure. See the
[recipe docs](./schemas) for individual recipe schemas.

## Why

Users hosting sensitive data on Google Cloud typically complete common and
repetitive processes such as setting up devops (Remote state, CICD), auditing,
and monitoring. By using out-of-the-box end-to-end configs that implement these
steps for you, you can quickly set up a secure and compliant environment and
focus on the parts of the infrastructure that drive your business.

This tool helps you follow Google Cloud and Terraform best practices:

- Clearly define your
    [resource hierarchy](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#define-hierarchy)
    in infra-as-code.

  - For example, the
        [org foundation example](../../examples/tfengine/org_foundation.hcl) can
        be used to define org level components and folders. Then, the
        [sample team example](../../examples/tfengine/team.hcl) can be used to
        define projects and resources within one of the folders.

- Break up Terraform state files into
    [logical deployments](https://www.hashicorp.com/resources/evolving-infrastructure-terraform-opencredo/)
    with remote state enabled.

  - For example, the
        [org foundation example](../../examples/tfengine/org_foundation.hcl)
        creates the Terraform root modules `devops`, `cicd`, `audit`, `monitor`,
        `folders`, etc.

- Set up GCP Organization Policy Constraints for security best practices.

  - For example, the [org policy recipe](./schemas/org_policies.md) can be
        used to configure and generate best practice
        [GCP Organization Policy Constraints](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)
        to help align your GCP infrastructure with HIPAA requirements.

- Work towards alignment with HIPAA and compliance requirements for
    [auditing and monitoring](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#logging_monitoring_and_operations).

  - For example, the [audit recipe](./schemas/audit.md) creates a dedicated
        project to host audit logs and creates logs routers to export all audit
        logs to BigQuery (for 1 year) and to GCS (for 7 years). These
        configurations help align with
        [HIPAA audit log](https://www.securitymetrics.com/blog/what-are-hipaa-compliant-system-logs)
        requirements.

- Reduce human access to the org infrastructure. Promote coding and version
    control best practices.

  - For example, the [CICD recipe](./schemas/cicd.md) sets up a pipeline
        that is run by Cloud Build service accounts. Through integration with
        Github, changes to infrastructure can be made via pull requests. The
        hooks we set up will automatically display the latest Terraform plan so
        users can be confident in their changes. The changes can be
        automatically applied when the pull request gets merged.

- Allow logical folders within your hierarchy to be managed independently,
    thus reducing org-wide broad access to single service account and chances of
    cascading errors.

  - For example, the [devops recipe](./schemas/devops.md) can be used on
        different folders to setup a separate CICD pipeline and service account
        to manage projects and resources within the folder. The service accounts
        of other CICD pipelines cannot access these projects.

- Define many security sensitive resources such as
    [centralized VPC networks](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#networking_and_security)
    and storage resources.

  - For example, the [project recipe](./schemas/project.md) can be used to
        create projects and resources within projects.

- Benefit from per-service best practices through use of the
    [Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit).

  - Our recipes use Cloud Foundation Toolkit modules wherever they make
        sense. When there are multiple options, we choose the most secure
        option. For example, creating a GKE cluster through our
        [project recipe](./schemas/project.md) will utilize the
        [safer GKE cluster](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/safer-cluster-update-variant)
        module from Cloud Foundation Toolkit.

## Prerequisites

1. Install the following dependencies and add them to your PATH:

    - [gcloud](https://cloud.google.com/sdk/gcloud)
    - [Terraform 0.12.29](https://releases.hashicorp.com/terraform/)
        (consistent with the version of Terraform used by CICD)
    - [Go 1.14+](https://golang.org/dl/)

1. Familiarize yourself with the tools you'll use:

    - [Google Cloud](https://cloud.google.com/docs/overview)
    - [Terraform](https://www.terraform.io/intro/index.html)

    The infrastructure is deployed using Terraform, which is an industry
    standard for defining infrastructure-as-code.

1. Set up your
    [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization)
    or
    [folder](https://cloud.google.com/resource-manager/docs/creating-managing-folders)
    for Google Cloud resources.

1. [Create](https://support.google.com/a/answer/33343?hl=en) the following
    administrative
    [IAM](https://cloud.google.com/iam/docs/overview#concepts_related_identity)
    groups manually so they can be used in the `devops` deployment:

    - {PREFIX}-{org|folder}-admins@{DOMAIN}: Members of this group get
        administrative access to the org or folder. This group can be used in
        break-glass situations to give humans access to the org or folder to
        make changes.

    - {PREFIX}-devops-owners@{DOMAIN}: Members of this group get owners access
        to the devops project to make changes to the CICD project or to make
        changes to the Terraform state.

    For example, for an org deployment with sample prefix "gcp" and domain
    "example.com", the admin group "gcp-org-admins@example.com" would be
    created.

    WARNING: The best practice is to always deploy changes using CICD. The
    privileged groups should remain empty and only have humans added for
    emergency situations or when investigation is required. This does not apply
    to view-only groups such as cicd-viewers.

    Once `devops` deployment is completed. More groups can be created and
    managed automatically by using the `groups` resource. See the `template
    "groups"` section in [team.hcl](../../examples/tfengine/team.hcl) for an
    example.

1. The running user will need to be a Google Workspace Super Admin and have the
    following Cloud IAM roles:

    - `roles/resourcemanager.organizationAdmin` on the org for org deployment
    - `roles/resourcemanager.folderAdmin` on the folder for folder deployment
    - `roles/resourcemanager.projectCreator` on the org or folder
    - `roles/compute.xpnAdmin` on the org or folder
    - `roles/billing.admin` on the billing account

## Defining Architecture

Plan out your org architecture and map them to engine configs. Our configs can
help you setup a wide variety of architectures that suit your needs.

As a rule of thumb, we recommend having one org config that sets up core
security and compliance infrastructure such as auditing, monitoring and org
policies. It should define a devops project to manage Terraform state and a CICD
pipeline. You can also use this config to define the org's folder hierarchy. We
recommend creating a folder for each team and major application in the org.

To define projects for a team or application, we recommend having a separate
config. These configs should set the root parent folder to be one of the folders
setup by the org config. Each config should define a devops project to manage
Terraform state and a CICD pipeline.

You may wish to replicate the configs across multiple environments (dev,
staging, etc).

All configs and the generated Terraform code should be checked into version
control. You can use a separate repo for each CICD pipeline. Note if using
GitHub you can share a single repo but with different paths within the repo. For
Cloud Source Repository, you must use a repo within each individual devops
project.

## Installation

Download a pre-built
[tfengine binary](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/):

```shell
VERSION=v0.4.0
wget -O /usr/local/bin/tfengine https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/download/${VERSION}/tfengine_${VERSION}_linux-amd64
chmod +x /usr/local/bin/tfengine
```

or build it yourself:

```shell
git clone https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite
cd healthcare-data-protection-suite
go install ./cmd/tfengine
```

## Usage

The engine takes a path to an input config and a path to output the generated
Terraform configs. For details on fields for the input schemas, see the
[schemas](./schemas) directory. The input config can use
[Go templates](https://golang.org/pkg/text/template/#hdr-Actions) to
programmatically express the resources being deployed. After the output has been
generated, there is no longer a dependency on the engine and the user can
directly use the `terraform` binary to deploy the infrastructure.

1. Replace the values in a suitable [example](../../examples/tfengine) with
    values for your infrastructure. Save it as a separate file called
    `config.hcl` and copy it to your local configs repo root directory.

    Project and Bucket names are globally unique and must be changed from
    defaults. You will get an error if you have chosen a name that is already
    taken.

    TIP: Prefer to remotely fetch templates from a release which can be more
    stable than using the HEAD templates.

    ```hcl
    template "devops" {
      recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/devops.hcl?ref=templates-v0.4.0"
      output_path = "./devops"
      data = {
        ...
      }
    }
    ```

1. To set up helper environment vars, run the following commands:

    ```shell
    GIT_ROOT=/path/to/your/local/configs/repo
    CONFIG_PATH=$GIT_ROOT/config.hcl
    OUTPUT_PATH=$GIT_ROOT/terraform
    ```

    **NOTE**: If you plan to set up CICD, the `terraform_root` variable in the
    CICD template should correspond to the parent directory in `OUTPUT_PATH`
    that would be checked into source control, i.e. `terraform` in the above
    setup.

1. Run the engine to generate your Terraform configs:

    ```shell
    tfengine --config_path=$CONFIG_PATH --output_path=$OUTPUT_PATH
    ```

    Each generated folder typically contains the following files:

    - **main.tf**: This file defines the Terraform resources and modules to
        manage.

    - **variables.tf**: This file defines any input variables that the
        deployment can take.

    - **outputs.tf**: This file defines any outputs from this deployment.
        These values can be used by other deployments.

    - **terraform.tfvars**: This file defines values for the input variables.

1. Set up the devops project to host the Terraform state and CICD:

    1. Deploy the `devops` project and Terraform state bucket.

        ```shell
        cd $OUTPUT_PATH/devops
        terraform init
        terraform apply
        ```

        Your `devops` project should now be ready.

    1. In $CONFIG_PATH, set `enable_gcs_backend` to `true`, and regenerate the
        Teraform configs.

        ```shell
        tfengine --config_path=$CONFIG_PATH --output_path=$OUTPUT_PATH
        ```

    1. Backup the state of the `devops` project to the newly created state
        bucket by running the following command.

        ```shell
        terraform init -force-copy
        ```

1. (Optional) Create Cloud Identity Groups for coming IAM role assignments.

    It is recommended to
    [delegate responsibility](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations#groups-and-service-accounts)
    through groups and service accounts so that individuals only obtain
    permissions through groups rather than direct IAM roles.

    1. Add a separate template called `groups` using the `project.hcl` recipe,
        and define your groups and memberships in the `resources` block. Set the
        `project_id` to the `devops` project ID and `exists` to `true`.

        ```hcl
        template "groups" {
          recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
          output_path = "./groups"
          data = {
            project = {
              project_id = "example-devops"
              exists     = true
            }
            resources = {
              groups = [
                {
                  id = "example-group@example.com"
                  customer_id = "c12345678"
                  owners = ["user1@example.com"]
                  members = ["user2@example.com"]
                },
              ]
            }
          }
        }
        ```

    1. Create groups and initial memberships. You must be at least Google
        Workspace Group Admin to be able to do so.

        ```shell
        cd $OUTPUT_PATH/groups
        terraform init
        terraform apply
        ```

1. (Optional) To deploy Continuous Integration (CI) and Continuous Deployment
    (CD) resources, follow the instructions
    [here](../../templates/tfengine/components/cicd/README.md) or equivalently,
    `$OUTPUT_PATH/cicd/README.md` in the generated Terraform configs directory.

    Your devops project and CICD pipelines are ready. The following changes
    should be made as Pull Requests (PRs) and go though code reviews. After
    approval is granted and CI tests pass, merge the PR. The CD job
    automatically deploys the change to your Google Cloud infra.

    If you would like to enable CICD to manage groups for you:

    1. Include `groups` in the `managed_dirs` of `cicd` template.
    1. Follow manual steps
        [here](https://cloud.google.com/identity/docs/how-to/setup#assigning_an_admin_role_to_the_service_account)
        to assign the CICD service account Group Admin role. You must be a
        Google Workspace Super Admin to be able to do so.

    Note that the `groups` template must be deployed manually first if you also
    use it to create groups to be used in the `cicd` template. These groups
    should exist before `cicd` template can be deployed.

1. Deploy org infrastructure and other resources by sending a PR for local
    changes to the config repo.

1. Follow the instructions of all commented out blocks starting with
    `TODO(user)` in the config to deploy the changes. Remove the comment once
    done.

## Tips

- If you plan on using the engine again, do not manually modify any generated
    file as it will be overwritten the next time the engine runs. Instead,
    prefer to change the input config, recipe, or component for the generated
    files and add new resources under new deployments that are not generated by
    the engine.

- Always back up any engine configs as well as the generated Terraform configs
    and any modifications to the Terraform configs to version control.

- Any component file with the extension `.tmpl` will have it removed when
    generated.

## Continuous integration (CI) and continuous deployment (CD)

See CICD specific documentations
[here](../../templates/tfengine/components/cicd/README.md).

If you are setting up a multi environment workflow (dev, staging, prod), see
[multi_envs.hcl](../../examples/tfengine/multi_envs.hcl) for an example config.
