# Secrets

The secrets deployment is used to define sensitive values that should not be
set in plaintext. Secrets are deployed in the devops project.

## How-to

1. Add a call for the secrets template in your engine config.

   ```hcl
   template "secrets" {
     recipe_path = "./recipes/project/secrets.hcl"
     output_path = "./secrets"
     data = {
       project_id = "example-devops"
       secrets = [{
         secret_id = "manual-sql-db-password"
       }]
     }
   }
   ```

1. For each secret, decide whether the secret should be set manually or
   automatically. Name your secret with a prefix notating this (e.g.
   `manual-db-user`, `auto-db-password`).

1. Add the new secrets in the template call.

1. In the deployment that needs to access the secret value, use the data source:

   ```hcl
   terraform_addons = {
    raw_config = <<EOF
    data "google_secret_manager_secret_version" "db_password" {
        provider = google-beta

        secret  = "manual-sql-db-password"
        project = "example-data"
    }
    EOF
   }
   ```

1. If the secret is manual, set the value in the GCP console secret manager
   page.
