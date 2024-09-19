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
