# Terraform Engine Deployment Debugging Guide

## Authentication Errors

1. Terraform uses
    [Google Cloud Application Default Credentials (ADC)](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login)
    for authentication to Google Cloud. To configure:

    1. Run `gcloud auth application-default login` from your terminal;
    1. Login in with your desired account;
    1. Make sure the environment variable `GOOGLE_APPLICATION_CREDENTIALS` is
        set to `~/.config/gcloud/application_default_credentials.json`, which is
        where the previous command write your credentials.

## GCP Errors

Follow these steps if you are able to successfully deploy resources (e.g.
`terraform apply` succeeds), but the resource in GCP is encountering errors.

1. Inspect the generated Terraform configs and ensure they match what you
    expect. If a field is misconfigured, update your engine hcl config
    accordingly. If a field is missing or is implemented incorrectly, file an
    issue in our Github repo.

1. If the Terraform config looks OK and the resource is implemented as a
    [Cloud Foundation Toolkit module](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/master/docs/terraform.md),
    you may need to investigate the specific module.

    *Tip:* It can also help to take a subset of configs and deploy them
    independently in Terraform on a dev project. Try to reproduce the issue then
    tweak fields and configs in the CFT module and see if that helps.

    *Tip:* The CFT module repo should also have more detailed documentation and
    examples on how to use the module which you should try to emulate.

1. For missing documentation or bugs on a CFT module, file an issue or send a
    PR to the module repo directly.

1. If you still can't get the resource to work with Terraform directly,
    consider creating the resource through GCP console on a dev version of the
    project.

    If this fixes it, go back to the previous steps and tweak your Terraform
    configs and/or underlying modules until they are working. You should then
    clean up by deleting any manually created resources and recreate them
    through Terraform to verify they work.
