module "sentry" {
  count  = var.enable_sentry ? 1 : 0
  source = "../sentry_project"

  repo_name                = local.normalized_repo
  platform                 = var.sentry_platform
  sentry_organization_slug = var.sentry_organization_slug
  sentry_team_slug         = var.sentry_team_slug
}
