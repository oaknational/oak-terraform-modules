locals {
  sentry_env_vars = var.enable_sentry ? [
    {
      name  = "SENTRY_DSN"
      value = var.sentry_dsn
    },
    {
      name  = "SENTRY_ENVIRONMENT"
      value = var.env
    }
  ] : []
}