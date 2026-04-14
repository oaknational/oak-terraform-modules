output "sentry_environment_variable_names" {
  description = "Sentry environment variables added to this project."
  value       = var.enable_sentry ? "The following Sentry environment variables have been added to the project: 'SENTRY_DSN', 'SENTRY_ENVIRONMENT'" : ""
}
