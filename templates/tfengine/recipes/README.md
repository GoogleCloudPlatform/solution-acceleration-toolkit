# Terraform Engine Recipes

See markdown schemas for recipes [here](../../../docs/tfengine/schemas).

Recipes put the building blocks defined by [components](../components) into
usable, end to end deployments.

Users can modify the recipes and add their own if they wish to do so in their
own forks.

## Example

Users can use the [audit recipe](./audit.hcl) which in turn calls the
[project recipe](./project.hcl) and [audit component](../components/audit).

The output is a dedicated audit project and log routers exporting audit logs to
storage resources within the audit project.
