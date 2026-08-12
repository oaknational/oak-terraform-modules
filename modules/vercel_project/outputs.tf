output "sentry_environment_variable_names" {
  description = "Sentry environment variables added to this project."
  value       = var.enable_sentry ? "The following Sentry environment variables have been added to the project: 'SENTRY_DSN', 'SENTRY_ENVIRONMENT'" : ""
}

output "project_id" {
  description = "The Vercel project ID."
  value       = vercel_project.this.id
}

output "project_name" {
  description = "The Vercel project name."
  value       = vercel_project.this.name
}

output "protection_bypass_for_automation_secret" {
  description = "The Vercel project token that allows automation services to bypass Deployment Protection."
  value       = vercel_project.this.protection_bypass_for_automation_secret
  sensitive   = true
}
