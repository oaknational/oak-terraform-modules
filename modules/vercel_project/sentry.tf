module "sentry" {
  count  = var.enable_sentry ? 1 : 0
  source = "../sentry_project"

  name_parts = {
    git_repo = local.normalized_repo
    suffix   = var.build_type
  }

  platform                 = var.sentry_platform
  sentry_organization_slug = var.sentry_organization_slug
  sentry_team_slug         = var.sentry_team_slug
}
