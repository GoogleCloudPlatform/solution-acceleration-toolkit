# Policy Generator Config Schema

<!-- These files are auto generated -->

## Properties

### forseti_policies

Key value pairs configure Forseti Policy Library constraints.

Type: object

### forseti_policies.allowed_policy_member_domains

The list of domains to allow users from, e.g. example.com

Type: array(string)

### forseti_policies.targets

List of targets to apply the policies, e.g. organizations/**,
organizations/123/folders/456.

Type: array(string)

### template_dir

Absolute or relative path to the template directory. If relative, this path
is relative to the directory where the config file lives.

Type: string

### version

Optional constraint on the binary version required for this config.
See [syntax](https://www.terraform.io/docs/configuration/version-constraints.html).

Type: string
