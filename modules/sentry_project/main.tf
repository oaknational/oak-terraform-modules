data "sentry_organization" "this" {
  slug = var.sentry_organization_slug
}

data "sentry_team" "this" {
  organization = data.sentry_organization.this.slug
  slug         = var.sentry_team_slug
}

locals {
  normalized_name = lower(replace("${var.name_parts.git_repo}-${var.name_parts.suffix}", "_", "-"))
}

resource "sentry_project" "this" {
  organization = data.sentry_organization.this.slug

  teams         = [data.sentry_team.this.slug]
  name          = local.normalized_name
  slug          = local.normalized_name
  platform      = var.platform
  default_rules = false
}

data "sentry_key" "this" {
  organization = sentry_project.this.organization
  project      = sentry_project.this.slug
  first        = true
}
