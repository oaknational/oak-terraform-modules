locals {
  function_records = { for f in var.functions : f.entrypoint => f }
}

module "functions" {
  for_each = local.function_records

  source = "../gcp_function"

  env                 = var.env
  name_parts          = var.name_parts
  google_cloud_region = var.google_cloud_region

  entrypoint             = each.value.entrypoint
  runtime                = each.value.runtime
  source_object          = each.value.source_object
  function_source_bucket = var.function_source_bucket

  max_instance_count      = each.value.max_instance_count
  available_memory_pwr    = each.value.available_memory_pwr
  timeout_seconds         = each.value.timeout_seconds
  available_cpu           = each.value.available_cpu
  max_request_concurrency = each.value.max_request_concurrency
  service_account_email   = each.value.service_account_email
  environment_variables   = each.value.environment_variables
  secrets                 = each.value.secrets

  description = "The API endpoint for ${var.env} ${join(" ", split("-", var.name_parts.app))}, ${each.key}"

}
