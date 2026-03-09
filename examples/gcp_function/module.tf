module "hosting" {
  source = "../../modules/gcp_function"

  # Follows the Oak standard naming convention
  name_parts = {
    domain = "xx"
    app    = "demo"
  }

  description = "Something descriptive of the function"

  env = var.env

  function_source_bucket = "example-code-storage-bucket"

  entrypoint    = "example_function"
  runtime       = "nodejs20"
  source_object = "example/api_${var.tag_id}.zip" 
  
  service_account_email = var.service_account_email

  environment_variables = [
    {
      name  = "ENV",
      value = var.env,
    },
  ]
  
  secrets = [
    {
      env_name    = "APP_SIGNING_KEY"
      secret_name = "app-${var.env}-signing-key" // From Google Secret Manager
    },
  ]
}
