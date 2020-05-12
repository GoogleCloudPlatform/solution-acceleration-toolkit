# Terraform Engine Recipes

Recipes put the building blocks defined by [Components](../components) into
usable, end to end deployments.

One recipe can define multiple Terraform deployments.

Users can modify the recipes and add their own if they wish to do so in their
own forks.

## Example

The [org foundation recipe](./org/foundation.yaml) sets up baseline
pieces for an organization. It calls several recipes, one being the
[audit recipe](./org/audit.yaml). The audit recipe in turn calls the
[org project recipe](./org/project.yaml) and
[org audit component](../components/org/audit).

The output of this is a fully setup base, with a dedicated audit project and log
routers exporting audit logs to storage resources within the audit project. The
deployments have the correct dependencies as well in order to be deployable.
