# Terraform Engine Recipes

Recipes put the building blocks defined by [components](../components) into
usable, end to end deployments.

One recipe can define multiple Terraform deployments.

Users can modify the recipes and add their own if they wish to do so in their
own forks.

## Example

The [audit recipe](./audit.yaml). The audit recipe in turn calls the
[project recipe](./project.yaml) and [audit component](../components/audit).

The output is a dedicated audit project and log routers exporting audit logs to
storage resources within the audit project. The deployments have the correct
dependencies as well in order to be deployable.
