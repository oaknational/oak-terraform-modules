# Google Cloud SQL

Deploys a single Cloud Run job which can be triggered by one or more cron schedules.

## Example

```hcl
module "instance" {
  source = "github.com/oaknational/oak-terraform-modules//modules/gcp_job"

  name_parts = {
    domain   = "eg"
    app      = "example"
    resource = "store"
  }

  env = "prod"

  docker_image = "europe-west2-docker.pkg.dev/example-org/xx/demo:v0.0.0"

  service_account_email = example@example-org.iam.gserviceaccount.com

  env_vars = [
    {
      name  = "ENV",
      value = var.env,
    },
  ]

  schedule = {
    crons = ["* * * * *"]
  }
}
```
