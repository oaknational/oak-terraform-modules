locals {
  tier_lookup = {
    "0.6" = "db-f1-micro"       # Shared 1 vCPU
    "1.7" = "db-g1-small"       # Shared 1 vCPU
    "3.7" = "db-custom-1-3840"  # 1 vCPU
    "8"   = "db-custom-2-8192"  # 2 vCPU
    "16"  = "db-custom-4-16384" # 4 vCPU
  }

  name = "${var.name_parts.domain}-${var.env}-${var.name_parts.app}-${var.name_parts.resource}"
}

resource "google_sql_database_instance" "this" {
  name             = local.name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier      = local.tier_lookup[var.memory]
    disk_type = "PD_SSD"

    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"

    # Insights are free so we might as well enable them
    insights_config {
      query_insights_enabled = true
    }

    maintenance_window {
      day  = 2 # Tuesday
      hour = 3
      # We want lower availability databases upgrading before higher...
      update_track = var.high_availability ? "week5" : "stable" # Stable is week 2
    }
  }
}