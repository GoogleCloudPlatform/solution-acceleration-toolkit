<!-- markdownlint-configure-file { "MD013": { "line_length": 120 } } -->
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

We have the following release tags:

* Ex. `v0.1.2` for binaries
* Ex. `templates-v0.1.2` for templates.
* Ex. `policies-v0.1.2` for policies.

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

WIP

## Manual releases

If automation is not available, releases can be made manually.

Optionally, consider using the [hub](https://github.com/github/hub) command instead of the GitHub UI for creating
releases.

### Version

1. Choose a version. It should match the regex `^v[0-9]+\.[0-9]+\.[0-9]+$`.
   That is, a leading "v", followed by three period-separated numbers.

   ```bash
   version="fill"
   ```

### Binaries

1. Create the Git tag:

   ```bash
   git tag -a "${version}" -m "Binaries release version ${version}"
   git push origin --tags
   ```

1. Build the binaries:

   ```bash
   ./build/build-binaries.sh -v "${version}"
   ```

   This will create binaries for each tool for each supported OS and ARCH.

1. Go to the [releases page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/).

1. Create a release from the `${version}` tag and upload all the `tfengine_*`,
   `policygen_*` and `tfimport_*` binaries as assets.

### Templates

1. Create the Git tag:

   ```bash
   git tag -a "templates-${version}" -m "Terraform Engine templates release version ${version}"
   git push origin --tags
   ```

1. Bundle the templates:

   ```bash
   ./build/build-templates.sh -v "${version}"
   ```

   This will create a .tar.gz bundle for the Terraform Engine templates.

1. Go to the [releases page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/).

1. Create a release from the `templates-${version}` tag and upload the
   `templates_${version}.tar.gz` file as an asset.

### Policies

1. Create the Git tags:

   ```bash
   git tag -a "policies-${version}" -m "Policygen policies release version ${version}"
   git push origin --tags
   ```

1. Bundle the policies:

   ```bash
   ./build/build-policies.sh -v "${version}"
   ```

   This will create a .tar.gz bundle for the Policy Generator policies.

1. Go to the [releases page](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite/releases/).

1. Create a release from the `policies-${version}` tag and upload the `policies_${version}.tar.gz` file as an asset.
