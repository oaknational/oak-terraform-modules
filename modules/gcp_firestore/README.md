# Google Cloud Firestore

Deploys a single Firestore instance with associated indexes and possibly backups.

## Example

```hcl
module "firestore" {
  source = "github.com/oaknational/oak-terraform-modules//modules/gcp_firestore"

  name_parts = {
    domain   = "eg"
    app      = "example"
    resource = "store"
  }

  env = "prod"

  backup = {
    frequency     = "w"
    retention     = 28
    day           = 0
    point_in_time = true
  }

  indexes = [
    {
      collection = "example"
      fields = [
        {
          path = "date"
        },
        {
          path = "user"
        },
      ]
    }
  ]

  use_optimistic_concurrency = true
}
```
