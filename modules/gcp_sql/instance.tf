locals {
  tier_lookup = {
    "0.6" = "db-f1-micro"       # Shared 1 vCPU
    "1.7" = "db-g1-small"       # Shared 1 vCPU
    "3.7" = "db-custom-1-3840"  # 1 vCPU
    "8"   = "db-custom-2-8192"  # 2 vCPU
    "16"  = "db-custom-4-16384" # 4 vCPU
  }

  name = join("-", [
    var.name_parts.domain, var.env, var.name_parts.region, var.name_parts.app, var.name_parts.resource
  ])

  authorized_network_records = {
    for an in var.authorized_networks : an.cidr => an.description
  }
}

resource "google_sql_database_instance" "this" {
  name             = local.name
  database_version = "POSTGRES_14"
  region           = var.region

  deletion_protection = var.deletion_protection

  settings {
    tier      = local.tier_lookup[var.memory]
    disk_type = "PD_SSD"

    availability_type           = var.high_availability ? "REGIONAL" : "ZONAL"
    deletion_protection_enabled = var.deletion_protection

    dynamic "backup_configuration" {
      for_each = toset((var.backup.backup_retention + var.backup.transaction_log_retention) > 0 ? [{}] : [])

      content {
        point_in_time_recovery_enabled = var.backup.transaction_log_retention > 0 ? true : false
        transaction_log_retention_days = var.backup.transaction_log_retention > 0 ? var.backup.transaction_log_retention : null

        enabled    = var.backup.backup_retention > 0 ? true : false
        start_time = var.backup.backup_time

        dynamic "backup_retention_settings" {
          for_each = toset(var.backup.backup_retention > 0 ? [{}] : [])

          content {
            retained_backups = var.backup.backup_retention
            retention_unit   = "COUNT"
          }
        }
      }
    }

    # Insights are free so we might as well enable them
    insights_config {
      query_insights_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.vpc_network_link
      ssl_mode        = "ENCRYPTED_ONLY"

      dynamic "authorized_networks" {
        for_each = local.authorized_network_records

        content {
          name  = authorized_networks.value
          value = authorized_networks.key
        }
      }
    }

    maintenance_window {
      day  = 2 # Tuesday
      hour = 3
      # We want lower availability databases upgrading before higher...
      update_track = var.high_availability ? "week5" : "stable" # Stable is week 2
    }

    password_validation_policy {
      min_length                  = 15 # Per MoJ guidelines for admin level access
      complexity                  = "COMPLEXITY_DEFAULT"
      disallow_username_substring = true
      enable_password_policy      = true
    }
  }
}

resource "google_storage_bucket_iam_member" "this" {
  for_each = toset(compact([var.export_bucket]))

  bucket = each.key
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_sql_database_instance.this.service_account_email_address}"
}

