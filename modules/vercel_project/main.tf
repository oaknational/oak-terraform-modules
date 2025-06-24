locals {
  repo_only = split("/", var.git_repo)[1]

  normalized_repo = lower(replace(local.repo_only, "_", "-"))

  project_name = "${local.normalized_repo}-${var.build_type}"
}

resource "vercel_project" "this" {
  name                             = local.project_name
  framework                        = var.framework
  build_command                    = var.build_command
  ignore_command                   = var.ignore_command
  skew_protection                  = var.skew_protection
  protection_bypass_for_automation = var.protection_bypass_for_automation
  output_directory                 = var.output_directory

  vercel_authentication = {
    deployment_type = var.deployment_type
  }

  root_directory = var.root_directory
  git_repository = {
    type              = "github"
    repo              = var.git_repo
    production_branch = var.production_branch
  }
}

resource "vercel_project_domain" "this" {
  for_each = toset(var.domains)

  project_id = vercel_project.this.id
  domain     = each.key
}

resource "vercel_project_environment_variables" "this" {
  project_id = vercel_project.this.id
  variables = [
    for ev in var.environment_variables : {
      key       = ev.key
      value     = ev.value
      target    = ev.target
      sensitive = ev.sensitive
    }
  ]
}

resource "vercel_deployment" "this" {
  depends_on = [vercel_project_environment_variables.this]

  project_id = vercel_project.this.id
  ref        = var.production_branch
  production = false
}