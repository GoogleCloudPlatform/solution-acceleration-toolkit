# Terraform Engine Component Development Guide

## New Resource

1. Verify if the resource already exists in the resources
    [list](./schemas/resources.md).

1. If it does not exist, add a new
    [component](../../templates/tfengine/components/resources).

    See
    [Storage Buckets](../../templates/tfengine/components/resources/storage_buckets)
    for an example to copy.

1. When implementing the template, prefer to use
    [Cloud Foundation Toolkit](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/master/docs/terraform.md)
    modules.

    If none is available, consider writing a new CFT module if you anticipate it
    would be useful to the community (or file a
    [feature request](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/issues)).

    If a module would not add much value, use a resource directly from the
    [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs).

1. Add the resource in
    [resources recipe](../../templates/tfengine/recipes/resources.hcl).

1. Add an example in the
    [team module](../../examples/tfengine/modules/team.hcl).

1. Regenerate docs and examples by running `scripts/regen.sh` from the root
    repo dir.

1. Run `go test ./...` from root repo dir to verify the resource works as
    intended.

## New Field

This should be done if the resource already exists.

1. Add the field in the resource's
    [component](../../templates/tfengine/components/resources).

    *Note*: If the resource uses a Cloud Foundation Toolkit module, you may need
    to add the field there first by sending a pull request and then waiting for
    a release.

1. Update the
    [resource schema](../../templates/tfengine/recipes/resources.hcl).

1. Add an example in the
    [team module](../../examples/tfengine/modules/team.hcl).

1. Regenerate docs and examples by running `scripts/regen.sh` from the root
    repo dir.

1. Run `go test ./...` from root repo dir to verify the resource works as
    intended.
