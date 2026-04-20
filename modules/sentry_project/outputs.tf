output "dsn" {
  description = "The DSN for the Sentry project."
  value       = data.sentry_key.this.dsn.public
  sensitive   = true
}
