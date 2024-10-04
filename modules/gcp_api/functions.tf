data "google_project" "current" {}

locals {
  function_records = { for f in var.functions : f.entrypoint => f }

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
  for_each = local.function_records

  name        = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}-${lower(each.value.entrypoint)}"
  location    = var.google_cloud_region
  description = "The API endpint for ${var.env} ${join(" ", split("-", var.name_parts.app))}, ${each.key}"

  build_config {
    runtime           = each.value.runtime
    entry_point       = each.value.entrypoint
    docker_repository = "${data.google_project.current.id}/locations/${var.google_cloud_region}/repositories/gcf-artifacts"
    source {
      storage_source {
        bucket = var.function_source_bucket
        object = each.value.source_object
      }
    }
  }

  service_config {
    max_instance_count = each.value.max_instance_count
    available_memory   = local.memory_lookup[each.value.available_memory_pwr]
    timeout_seconds    = each.value.timeout_seconds

    available_cpu                    = each.value.available_cpu == 0 ? null : each.value.available_cpu
    max_instance_request_concurrency = each.value.max_request_concurrency

    service_account_email = each.value.service_account_email

    environment_variables = {
      for e in each.value.environment_variables : e.name => e.value
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

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  for_each = local.function_records

  location    = google_cloudfunctions2_function.this[each.key].location
  name        = google_cloudfunctions2_function.this[each.key].name
  policy_data = data.google_iam_policy.all_users.policy_data
}