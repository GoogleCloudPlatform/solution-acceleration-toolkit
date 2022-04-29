# Google Cloud Healthcare Data Protection Suite

Stable releases:

![version](https://img.shields.io/github/v/release/GoogleCloudPlatform/healthcare-data-protection-suite?color=green&label=Binaries&sort=semver)

This repository contains a suite of tools that can be used to manage key areas
of your Google Cloud organization.

- Deploy
- Monitor
- Audit

## Tools

- [Terraform Engine](./docs/tfengine): Generate end-to-end infra-as-code for
    Google Cloud with security, compliance, and best practices built in.

- [Policy Generator](./docs/policygen): Generate best practices policies for
    Forseti and other monitoring solutions, customized for your infra.

- [Terraform Importer](./docs/tfimport): Automatically detect and import
    existing resources defined by your Terraform configs.

## Tutorial Video

[Deploying the Data Protection Toolkit](https://www.youtube.com/watch?v=-wIutctaqr0)

Note that YAML-formatted configs were used at the time when the Tutorial video
was made. The config format has been changed to
[HCL](https://github.com/hashicorp/hcl).

## Releases

Please see [RELEASING.md](./RELEASING.md) for our release strategy.
