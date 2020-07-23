schema = {
  title                = "CICD Recipe"
  additionalProperties = false
  properties = {
    project_id = {
      description = "ID of project to deploy CICD in."
      type        = "string"
    }
    github = {
      description          = "Config for GitHub Cloud Build triggers."
      type                 = "object"
      additionalProperties = false
      properties = {
        owner = {
          description = "GitHub repo owner."
          type        = "string"
        }
        name = {
          description = "GitHub repo name."
          type        = "string"
        }
      }
    }
    cloud_source_repository = {
      description          = "Config for Google Cloud Source Repository Cloud Build triggers."
      type                 = "object"
      additionalProperties = false
      properties = {
        name = {
          description = <<EOF
            Cloud Source Repository repo name.
            The Cloud Source Repository should be hosted under the devops project.
          EOF
          type        = "string"
        }
      }
    }
    branch_regex = {
      description = "Regex of the branches to set the Cloud Build Triggers to monitor."
      type        = "string"
    }
    terraform_root = {
      description = "Path of the directory relative to the repo root containing the Terraform configs."
      type        = "string"
    }
    build_viewers = {
      description = <<EOF
        IAM members to grant `cloudbuild.builds.viewer` role in the devops project
        to see CICD results.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    managed_directories = {
      description = "List of directories managed by the CICD relative to terraform_root."
      type        = "array"
      items = {
        type = "string"
      }
    }
    managed_services = {
      description = <<EOF
        APIs to enable in the devops project so the Cloud Build service account
        can manage those services in other projects.
      EOF
      type        = "array"
      items = {
        type = "string"
      }
    }
    validate_trigger = {
      description = <<EOF
        Config block for the presubmit validation Cloud Build trigger. If specified, create
        the trigger and grant the Cloud Build Service Account necessary permissions to perform
        the build.
      EOF
      type                 = "object"
      additionalProperties = false
      properties = {
        disable = {
          description = <<EOF
            Whether or not to disable automatic triggering from a PR/push to branch. Default
            to false.
          EOF
          type        = "boolean"
        }
      }
    }
    plan_trigger = {
      description = <<EOF
        Config block for the presubmit plan Cloud Build trigger.
        If specified, create the trigger and grant the Cloud Build Service Account
        necessary permissions to perform the build.
      EOF
      type                 = "object"
      additionalProperties = false
      properties = {
        disable = {
          description = <<EOF
            Whether or not to disable automatic triggering from a PR/push to branch.
            Defaults to false.
          EOF
          type        = "boolean"
        }
      }
    }
    apply_trigger = {
      description = <<EOF
        Config block for the postsubmit apply/deployyemt Cloud Build trigger.
        If specified,create the trigger and grant the Cloud Build Service Account
        necessary permissions to perform the build.
      EOF
      type                 = "object"
      additionalProperties = false
      properties = {
        disable = {
          description = <<EOF
            Whether or not to disable automatic triggering from a PR/push to branch. Default
            to false.
          EOF
          type        = "boolean"
        }
      }
    }
  }
}

template "cicd" {
  component_path = "../components/cicd"
}
