# Google Cloud Healthcare Data Protection Suite

This repository contains a suite of tools that can be used to manage key areas
of your GCP organization.

- Deploy
- Monitor
- Audit

## Tools

- [Terraform Engine](./cmd/tfengine): Generate end to end infra-as-code for
    GCP with security, compliance and best practices built in.

- [Policy Generator](./cmd/policygen): Generate best practices policies for
    Forseti and other monitoring solutions, customized for your infra.

- [Terraform Importer](./cmd/tfimport): Automatically detect and import
    existing resources defined by your Terraform configs.
