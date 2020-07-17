<!-- markdownlint-configure-file { "MD013": { "line_length": 200 } } -->
# Releasing

## Overview

This repo contains three types of release artifacts:

* **Go Binaries** for [Terraform Engine](./docs/tfengine), [Policy Generator](./docs/policygen), and [Terraform Importer](./docs/tfimport).
* **Templates** for the Terraform Engine ("templates" for short).
* **Policy templates** for the Policy Generator ("policies" for short).

These three groups of artifacts are not coupled with each other, so they are **released separately**.

### Versioning

Releases are tagged with [Git Annotated Tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging) following [semantic
versioning](https://semver.org/) (semver):

* `v1.x.x` - MAJOR version, increments on breaking changes.
* `v1.2.x` - MINOR version, increments on backwards-compatible new features.
* `v1.2.3` - PATCH version, increments on backwards-compatible bug fixes.

The only exception to the above is the `0.x.x` version. As described in semver, this version is for initial development;
anything may change at any time, and the public API should not be considered stable.

We use the release tags `vX.X.X` for binaries, `templates-vX.X.X` for templates, and `policies-vX.X.X` for policies.
All templates are versioned together as one unit, and so are all policies.

Examples:

* [`v0.1.0`](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/tag/v0.1.0)
  for a binaries release
* [`templates-v0.1.0`](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/tag/templates-v0.1.0)
  for a templates release
* [`policies-v0.1.0`](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/tag/policies-v0.1.0)
  for a policies release.

### Release Branching

For now, we do not preemptively create release branches. Release tags are made on master by Repo Owners, and we
primarily work on the latest version of the binaries, templates and policies.

Release branches may be cut from old releases as necessary, but we would generally encourage using or migrating to the
latest versions of everything.

### Frequency

We strive to make a release at least once a month, containing accumulated changes since the last release. We may make
out-of-band releases any time as needed. We will bump the MAJOR/MINOR/PATCH versions as needed, without guarantees on
when the MINOR or MAJOR versions will be bumped.

### Caveat about versions

Solutions docs and guides should pin the versions of the binaries, templates and policies to ensure that users will see
consistent binary behaviour and output files.

However, as cloud APIs and other infrastructure change over time, in practice solutions may stop working even with the
same versions as before. We cannot guarantee indefinite compatibility, and encourage solutions and guide writers to
periodically check for correctness and consider updating to use the latest versions.

## Automated releases

Automated releases are configured to trigger on tag pushes, via
[GitHub Actions](https://github.com/features/actions). See the [workflows](./.github/workflows).

To trigger an automated release:

1. Choose a version. It should match the regex `^v[0-9]+\.[0-9]+\.[0-9]+$`.
   That is, a leading "v", followed by three period-separated numbers.

   ```bash
   version="fill"
   ```

1. Create the Git tag.

   For binaries:

   ```bash
   git tag -a "${version}" -m "Binaries release version ${version}"
   ```

   For templates:

   ```bash
   git tag -a "templates-${version}" -m "Terraform Engine templates release version ${version}"
   ```

   For policies:

   ```bash
   git tag -a "policies-${version}" -m "Policygen policies release version ${version}"
   ```

1. Push the tag:

   ```bash
   git push origin --tags
   ```

1. Follow the workflow on the
   [Actions page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/actions).

## Manual releases

If automation is not available, releases can be made manually. Follow the steps above to create and push a tag,
then manually build and upload the release artifacts as described below.

### Binaries

1. Build the binaries:

   ```bash
   ./build/build-binaries.sh -v "${version}"
   ```

   This will create binaries for each tool for each supported OS and ARCH.

1. Go to the [releases page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/).

1. Create a release from the `${version}` tag and upload all the `tfengine_*`,
   `policygen_*` and `tfimport_*` binaries as assets.

### Templates

1. Bundle the templates:

   ```bash
   ./build/build-templates.sh -v "${version}"
   ```

   This will create a .tar.gz bundle for the Terraform Engine templates.

1. Go to the [releases page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/).

1. Create a release from the `templates-${version}` tag and upload the `templates_${version}.tar.gz` file as an asset.

### Policies

1. Bundle the policies:

   ```bash
   ./build/build-policies.sh -v "${version}"
   ```

   This will create a .tar.gz bundle for the Policy Generator policies.

1. Go to the [releases page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/).

1. Create a release from the `policies-${version}` tag and upload the `policies_${version}.tar.gz` file as an asset.

### Using [Hub](https://github.com/github/hub) to create a release instead of the GitHub UI

You can use the [hub](https://github.com/github/hub) command instead of the GitHub UI for creating releases.
Follow instructions to install it, then run one of the following commands:

1. For binaries:

   ```bash
   hub release create $(printf -- ' --attach=%s' ./*-amd64) -m "Binaries release version ${version}" "${version}"
   ```

1. For templates:

   ```bash
   hub release create $(printf -- ' --attach=%s' ./templates*.tar.gz) -m "Terraform Engine templates release version ${version}" "${version}"
   ```

1. For policies:

   ```bash
   hub release create $(printf -- ' --attach=%s' ./policies*.tar.gz) -m "Policy Generator policies release version ${version}" "${version}"
   ```