output "sentry_environment_variable_names" {
  description = "The following environment variables have been added and are available for use by the Sentry SDK"
  value       = var.enable_sentry ? ["SENTRY_DSN", "SENTRY_ENVIRONMENT"] : []
}