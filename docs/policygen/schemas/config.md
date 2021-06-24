# Policy Generator Config Schema

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| forseti_policies | Key value pairs configure Forseti Policy Library constraints. | object | false | - | - |
| forseti_policies.allowed_policy_member_domains | The list of domains to allow users from, e.g. example.com | array(string) | false | - | - |
| forseti_policies.targets | List of targets to apply the policies, e.g. organizations/**,          organizations/123/folders/456. | array(string) | true | - | - |
| template_dir | Absolute or relative path to the template directory. If relative, this path      is relative to the directory where the config file lives. | string | true | - | - |
| version | Optional constraint on the binary version required for this config.      See [syntax](https://www.terraform.io/docs/configuration/version-constraints.html). | string | false | - | - |
