# Google Cloud Stand Alone function

Deploys a single Cloud Run function.

## Example

```hcl
module "example_api" {
  source = "github.com/oaknational/oak-terraform-modules//modules/gcp_function"

  name_parts = {
    domain   = "eg"
    app      = "example"
  }

  description = "My first example function"
  
  env = "prod"
  
  function_source_bucket = "example-code-storage-bucket"

  function = {
      entrypoint    = "example_function"
      runtime       = "nodejs20"
      source_object = "example/api.zip" 
      
      service_account_email = "example-api@example-project.iam.gserviceaccount.com"

      environment_variables = [
        {
          name  = "DATABASE_URL",
          value = "db.example.com",
        },
      ]
    }  
  }
}
```
