locals {
  tier_lookup = {
    "0.6" = "db-f1-micro"       # Shared 1 vCPU
    "1.7" = "db-g1-small"       # Shared 1 vCPU
    "3.7" = "db-custom-1-3840"  # 1 vCPU
    "8"   = "db-custom-2-8192"  # 2 vCPU
    "16"  = "db-custom-4-16384" # 4 vCPU
  }

  name = "${var.name_parts.domain}-${var.env}-${var.name_parts.app}-${var.name_parts.resource}"

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

    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"

    # Insights are free so we might as well enable them
    insights_config {
      query_insights_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.vpc_network_link
      require_ssl     = true

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

output "connection_data" {
  value = {
    external_ip = one([
      for ip in resource.google_sql_database_instance.this.ip_address : ip.ip_address if ip.type == "PRIMARY"
    ])
    internal_ip = one([
      for ip in resource.google_sql_database_instance.this.ip_address : ip.ip_address if ip.type == "PRIVATE"
    ])
    server_ca_cert = one([
      for ca in resource.google_sql_database_instance.this.server_ca_cert : ca.cert
    ])
  }
}
