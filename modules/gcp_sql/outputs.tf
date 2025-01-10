output "instance_name" {
  value = google_sql_database_instance.this.id
}

output "connection_name" {
  value = google_sql_database_instance.this.connection_name
}

output "ip_address" {
  value = {
    external_ip = one([
      for ip in resource.google_sql_database_instance.this.ip_address : ip.ip_address if ip.type == "PRIMARY"
    ])
    internal_ip = one([
      for ip in resource.google_sql_database_instance.this.ip_address : ip.ip_address if ip.type == "PRIVATE"
    ])
  }
}

output "server_ca_cert" {
  value = one([
    for ca in resource.google_sql_database_instance.this.server_ca_cert : ca.cert
  ])
}
