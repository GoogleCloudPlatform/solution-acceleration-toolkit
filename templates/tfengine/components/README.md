# Terraform Engine Components

Components are the building blocks of the Terraform Engine. They typically
define templatized Terraform configs which the engine then sends values to.

One component defines only one Terraform deployment. It may define a partial
deployment and expect other components to fill in any missing parts.
Typically this is done through [recipes](../recipes).

Users can modify the components and add their own if they wish to do so in their
own forks.

## Example

The [storage buckets](./project/storage_buckets) component allows users to
create multiple storage buckets inside a project. It will reference the project
id through a `var.project_id` reference. Thus, another component such as the
[terragrunt leaf](./terragrunt/leaf) component can be used to create a
dependency on the project deployment and pass in the `project_id` as an input.

The [project resources recipe](../recipes/project/resources.yaml) takes care of
this.
