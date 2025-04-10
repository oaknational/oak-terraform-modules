# Google Cloud API & Gateway

Deploys one or more Cloud run functions via an API gateway to a domain.

## Example

### The Open API YAML file

In order to use API Gateway you will need a valid Open API YAML file.

Note. Although this does need to include the paths section of the file schemas are not necessary
in the responses section for the file to be valid.

```yaml
swagger: "2.0"
info:
  title: Example file
  description: An example for documentation purposes
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /v1/response:
    get:
      operationId: getResponse
      summary: Responds to a GET request
      produces:
        - application/json
      x-google-backend:
        address: ${get_response_url}
      responses:
        "200":
          description: Everyone is happy
  /v1/update:
    post:
      operationId: setValue
      summary: Handles a POST request
      produces:
        - application/json
      x-google-backend:
        address: ${set_value_url}
      responses:
        "201":
          description: Everyone is happy

```

### The Terraform config

The above would be stored in a file called `example.yaml`.

In the same directory as that file should be the Terraform config...

```hcl

locals {
  entrypoints = [ "getResponse", "setValue" ]
}

module "example_api" {
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/oaknational/oak-terraform-modules//modules/gcp_api"

  name_parts = {
    domain   = "eg"
    app      = "example"
  }

  env = "prod"

  cloudflare_account_name = var.cloudflare_account_name
  cloudflare_zone_domain  = var.cloudflare_zone_domain
  sub_domain              = "eg"  # This would resolve to eg.{cloudflare_zone_domain_name}


  function_source_bucket = "example-code-storage-bucket"

  # Although you can code each function separately you will find most share common configs so a loop
  # with a merge function similar to this may help simplify config management
  functions = [for ep in local.entrypoints : merge(
    { entrypoint = ep },
    {
      runtime       = "nodejs20"
      source_object = "example/api.zip"

      service_account_email = "example-api@example-project.iam.gserviceaccount.com"

      environment_variables = [
        {
          name  = "DATABASE_URL",
          value = "db.example.com",
        },
      ]
    })
  ]

  gateway = {
    config_file    = "${path.module}/example.yaml"
    # The file name of the above yaml, assuming it is stored in the config root dir

    config_version = 1

    entrypoint_map = [
      {
        variable   = "get_response_url",  # This can be found in the example YAML above
        entrypoint = "getResponse",       # This is from local.entrypoints
      },
      {
        variable   = "set_value_url",
        entrypoint = "setValue",
      },
    ]
  }
}

output "function_uri" {
  value = module.hosting.function_uri
}
```
