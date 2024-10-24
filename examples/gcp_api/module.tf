provider "google" {
}

provider "google-beta" {
}

locals {
  entrypoints = toset(["getFunction", "putFunction"])
}

module "hosting" {
  source = "../../modules/gcp_api"

  # Follows the Oak standard naming convention
  name_parts = {
    domain = "xx"
    app    = "demo"
  }

  env = var.env

  cloudflare_account_name = var.cloudflare_account_name
  cloudflare_zone_domain  = var.cloudflare_zone_domain
  sub_domain              = "demo"

  google_cloud_region = var.region


  function_source_bucket = var.source_bucket

  functions = [for ep in local.entrypoints : {
    entrypoint = ep

    runtime       = "nodejs20"
    source_object = "demo/index.zip"

    max_instance_count      = 1
    available_cpu           = 1
    max_request_concurrency = 6

    service_account_email = var.service_account_email

    environment_variables = [
      {
        name  = "ENV",
        value = var.env,
      },
    ]
  }]

  gateway = {
    config_file    = "${path.module}/openapi.yaml"
    config_version = var.config_version
    entrypoint_map = [
      {
        variable   = "get_function_url", # As defined in the open api config yaml
        entrypoint = "getFunction",  # A function entrypoint name from above
      },
      {
        variable   = "put_function_url",
        entrypoint = "putFunction",
      },
    ]
  }
}

output "function_uri" {
  value = module.hosting.function_uri
}

