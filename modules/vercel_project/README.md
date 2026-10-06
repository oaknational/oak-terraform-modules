# Vercel Project Terraform Module

Terraform module for creating and managing a [Vercel project](https://vercel.com/docs/projects/overview).

## Enabling Sentry

In the `vercel_project` Terraform module, Sentry is managed internally and is created alongside the Vercel project itself. There are three variables you can set:

- `enable_sentry`
  - Whether to enable Sentry error tracking. In this case, where we want to use Sentry, we should set this to `true`.
- `sentry_team_slug`
  - The slug of the team to assign the project to within Sentry.

Items in the correct Terraform project will automatically apply the correct values for `sentry_organization_slug` but you **must** ensure you define the variable to satisfy the warning:

```hcl
variable "sentry_organization_slug" {
  description = "The slug of the Sentry organisation."
  type        = string
}
```

In doing so, it will add two additional environment variables:

- `SENTRY_DSN` which is the ingestion point for data created by your Vercel project.
- `SENTRY_ENVIRONMENT` is a duplicate of the standard `env`, and is used to show which environment was in use.

## Usage

```hcl
module "vercel_project" {
  source = "github.com/oaknational/oak-terraform-modules//modules/vercel_project"
  name = "my-project"
}
```
