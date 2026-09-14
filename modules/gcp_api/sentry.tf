data "terraform_remote_state" "sentry_project" {
  backend = "remote"

  config = {
    organization = var.sentry_organization_slug
    workspaces = {
      name = var.sentry_tf_workspace
    }
  }
}

locals {
  sentry_env_vars = var.enable_sentry ? [
    {
      name  = "SENTRY_DSN"
      value = data.terraform_remote_state.sentry_project.outputs.sentry_dsn
    },
    {
      name  = "SENTRY_ENVIRONMENT"
      value = var.env
    }
  ] : []
}