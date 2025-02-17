resource "google_firestore_database" "this" {
  name = join("-", [
    var.name_parts.domain, var.env, var.name_parts.region, var.name_parts.app, var.name_parts.resource
  ])
  location_id = var.region

  type = "FIRESTORE_NATIVE"

  concurrency_mode            = var.use_optimistic_concurrency ? "OPTIMISTIC" : "PESSIMISTIC"
  app_engine_integration_mode = "DISABLED"

  point_in_time_recovery_enablement = lookup(var.backup, "point_in_time", false) ? "POINT_IN_TIME_RECOVERY_ENABLED" : "POINT_IN_TIME_RECOVERY_DISABLED"
  delete_protection_state           = var.env == "prod" ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"
  deletion_policy                   = "DELETE"
}

locals {
  weekly_backup_day_lookup = [
    "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"
  ]
}

resource "google_firestore_backup_schedule" "this" {
  count = contains(["d", "w"], var.backup.frequency) ? 1 : 0

  database = google_firestore_database.this.name

  retention = "${(60 * 60 * 24) * var.backup.retention}s"

  dynamic "daily_recurrence" {
    for_each = var.backup.frequency == "d" ? { day = true } : {}

    content {}
  }

  dynamic "weekly_recurrence" {
    for_each = var.backup.frequency == "w" ? { week = true } : {}

    content {
      day = local.weekly_backup_day_lookup[var.backup.day]
    }
  }
}

locals {
  index_records = {
    for i in var.indexes : join("_", concat([i.collection], i.fields[*].path)) => i
  }
}

resource "google_firestore_index" "this" {
  for_each = local.index_records

  database   = google_firestore_database.this.name
  collection = each.value.collection

  dynamic "fields" {
    for_each = { for i, f in each.value.fields : i => f }

    content {
      field_path = fields.value.path
      order      = fields.value.asc ? "ASCENDING" : "DESCENDING"
    }
  }
}
