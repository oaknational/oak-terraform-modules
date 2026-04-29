data "sentry_organization" "this" {
  slug = var.sentry_organization_slug
}

data "sentry_team" "this" {
  organization = data.sentry_organization.this.slug
  slug         = var.sentry_team_slug
}

resource "sentry_project" "this" {
  organization = data.sentry_organization.this.slug

  teams         = [data.sentry_team.this.slug]
  name          = var.repo_name
  slug          = var.repo_name
  platform      = var.platform
  default_rules = false
}

data "sentry_key" "this" {
  organization = sentry_project.this.organization
  project      = sentry_project.this.slug
  first        = true
}
