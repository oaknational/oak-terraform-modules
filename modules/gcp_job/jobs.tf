locals {
  app_name_title  = title(replace(var.name_parts.app, "-", " "))
  env_var_records = { for v in var.environment_variables : v.name => v.value }
}

resource "google_cloud_run_v2_job" "this" {
  name = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}"

  location            = var.google_cloud_region
  deletion_protection = false

  template {
    template {
      containers {
        image = var.docker_image

        dynamic "env" {
          for_each = local.env_var_records

          content {
            name  = env.key
            value = env.value
          }
        }

        resources {
          limits = {
            cpu    = var.cpu_allocation
            memory = "${var.memory_allocation}Gi"
          }
        }
      }
      timeout = "600s"
    }
  }
}

resource "google_cloud_scheduler_job" "this" {
  for_each = toset(try(var.schedule.crons, []))

  name        = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}-cron"
  description = "Do a daily update of ${var.env} ${local.app_name_title}"
  schedule    = each.key
  time_zone   = var.schedule.time_zone

  region = var.google_cloud_region

  http_target {
    http_method = "POST"
    uri = join("", [
      "https://",
      google_cloud_run_v2_job.this.location,
      "-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/",
      google_cloud_run_v2_job.this.project,
      "/jobs/",
      google_cloud_run_v2_job.this.name,
      ":run"
    ])
    oauth_token {
      service_account_email = var.service_account_email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}
