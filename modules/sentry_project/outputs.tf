output "sentry_dsn" {
  description = "The DSN for the Sentry project."
  value       = data.sentry_key.this.dsn.public
  sensitive   = true
}

output "sentry_project_slug" {
  description = "The slug of the Sentry project, for downstream workspaces to look up its DSN."
  value       = sentry_project.this.slug
}