# Deployments

This directory defines custom Terraform configs for your infrastructure.

After [bootstrap/](../../bootstrap) has been deployed, you can deploy the
configs here by running

```bash
terraform init
terraform plan
terraform apply
```

If you configured and deployed [cicd/](../../cicd), then configs under this
directory are deployed by CICD pipelines.
