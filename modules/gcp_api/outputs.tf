output "function_uri" {
  value = "https://${cloudflare_record.cname.hostname}"
}