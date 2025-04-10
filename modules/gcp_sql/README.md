# Google Cloud SQL

Deploys a single Postgres database instance.

## Example

```hcl
module "instance" {
  source = "github.com/oaknational/oak-terraform-modules//modules/gcp_sql"

  name_parts = {
    domain   = "eg"
    app      = "example"
    resource = "store"
  }

  env = "prod"

  authorized_networks = {
    name            = "my-external-connections"
    value           = "1.2.3.4/32"
  }

  backup              = {
    backup_retention          = 20
    backup_time               = "01:30"
    transaction_log_retention = 7
  }

  export_bucket       = "my-example-sql-dump"
  high_availability   = true
  memory              = 3.7
  vpc_network_link    = "projects/example-project/global/networks/example-vpc"
}
```
