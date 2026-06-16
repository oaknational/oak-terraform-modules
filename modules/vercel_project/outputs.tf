output "sentry_environment_variable_names" {
  description = "Sentry environment variables added to this project."
  value       = var.enable_sentry ? "The following Sentry environment variables have been added to the project: 'SENTRY_DSN', 'SENTRY_ENVIRONMENT'" : ""
}

output "model_armor_environment_variable_names" {
  description = "Model Armor environment variables added to this project."
  value = var.enable_model_armor ? [
    "MODEL_ARMOR_AUTH_MODE",
    "MODEL_ARMOR_LOCATION",
    "MODEL_ARMOR_PROJECT_ID",
    "MODEL_ARMOR_SERVICE_ACCOUNT_EMAIL",
    "MODEL_ARMOR_TEMPLATE_ID",
    "MODEL_ARMOR_WORKLOAD_IDENTITY_PROVIDER_NAME",
    "MODEL_ARMOR_WORKLOAD_IDENTITY_POOL_ID",
    "MODEL_ARMOR_WORKLOAD_IDENTITY_POOL_PROVIDER_ID",
    "MODEL_ARMOR_WORKLOAD_IDENTITY_POOL_PROJECT_ID",
    "MODEL_ARMOR_WORKLOAD_IDENTITY_POOL_PROJECT_NUMBER",
  ] : []
}
