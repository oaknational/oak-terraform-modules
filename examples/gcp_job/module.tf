module "hosting" {
  source = "../../modules/gcp_job"

  # Follows the Oak standard naming convention
  name_parts = {
    domain = "xx"
    app    = "demo"
  }

  env = var.env

  docker_image = "europe-west2-docker.pkg.dev/example-org/xx/demo:${var.tag_id}"

  service_account_email = var.service_account_email

  env_vars = [
    {
      name  = "ENV",
      value = var.env,
    },
  ]

  schedule = {
    crons = ["25 * * * *"]
  }
}
