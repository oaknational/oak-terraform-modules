resource "google_firestore_database" "this" {
  name = join("-", [
    var.name_parts.domain, var.env, var.name_parts.region, var.name_parts.app, var.name_parts.resource
  ])
  location_id = var.region

  type = "FIRESTORE_NATIVE"

  concurrency_mode            = var.use_optimistic_concurrency ? "OPTIMISTIC" : "PESSIMISTIC"
  app_engine_integration_mode = "DISABLED"

  point_in_time_recovery_enablement = var.enable_point_in_time_recovery ? "POINT_IN_TIME_RECOVERY_ENABLED" : "POINT_IN_TIME_RECOVERY_DISABLED"
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
