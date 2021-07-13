# Recipe for iam bindings

<!-- These files are auto generated -->

## Properties

| Property | Description | Type | Required | Default | Pattern |
| -------- | ----------- | ---- | -------- | ------- | ------- |
| iam_bindings | [Module](https://github.com/terraform-google-modules/terraform-google-iam) | array(object) | false | - | - |
| iam_bindings.bindings | Map of IAM role to list of members to grant access to the role. | object | true | - | - |
| iam_bindings.parent_ids | Ids of the parent to assign the bindings. | array(string) | false | - | - |
| iam_bindings.parent_type | Type of the resource to assign the bindings. | string | true | - | ^storage_bucket\|project\|organization\|folder\|billing_account$ |
| state_bucket | Bucket to store remote state. | string | false | - | - |
