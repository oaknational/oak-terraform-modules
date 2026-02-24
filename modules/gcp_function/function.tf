data "google_project" "current" {}

locals {
  secrets = { for s in var.function.secrets : s.env_name => s.secret_name }
}

data "google_secret_manager_secret" "secrets" {
  for_each = local.secrets

  project   = data.google_project.current.project_id
  secret_id = each.value
}


locals {
  memory_lookup = [
    "128M",
    "256M",
    "512M",
    "1G",
    "2G",
    "4G",
    "8G",
    "16G",
    "32G",
  ]
}

resource "google_cloudfunctions2_function" "this" {
  name        = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}-${lower(replace(var.function.entrypoint, "_", "-"))}"
  location    = var.google_cloud_region
  description = var.description

  build_config {
    runtime           = var.function.runtime
    entry_point       = var.function.entrypoint
    docker_repository = "${data.google_project.current.id}/locations/${var.google_cloud_region}/repositories/gcf-artifacts"
    source {
      storage_source {
        bucket = var.function_source_bucket
        object = var.function.source_object
      }
    }
  }

  service_config {
    max_instance_count = var.function.max_instance_count
    available_memory   = local.memory_lookup[var.function.available_memory_pwr]
    timeout_seconds    = var.function.timeout_seconds

    available_cpu                    = var.function.available_cpu == 0 ? null : var.function.available_cpu
    max_instance_request_concurrency = var.function.max_request_concurrency

    service_account_email = var.function.service_account_email

    environment_variables = {
      for e in concat(
        var.function.environment_variables,
        # If one isn't explicitly declared add a LOG_EXECUTION_ID variable (as GCP will do this anyway)
        contains(
          [for e in var.function.environment_variables : e.name],
          "LOG_EXECUTION_ID"
          ) ? [] : [
          {
            name  = "LOG_EXECUTION_ID",
            value = true,
          }
        ]
      ) : e.name => e.value
    }

    dynamic "secret_environment_variables" {
      for_each = local.secrets

      content {
        key        = secret_environment_variables.key
        project_id = data.google_project.current.project_id
        secret     = data.google_secret_manager_secret.secrets[secret_environment_variables.key].secret_id
        version    = "latest"
      }
    }
  }

}

data "google_iam_policy" "all_users" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "this" {
  location    = google_cloudfunctions2_function.this.location
  name        = google_cloudfunctions2_function.this.name
  policy_data = data.google_iam_policy.all_users.policy_data
}
