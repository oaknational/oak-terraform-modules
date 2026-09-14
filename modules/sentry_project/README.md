# sentry_project

Responsible for creating [Sentry](sentry.io) project that will be used for error-tracking and application-monitoring. It replaces the previously used Bugsnag application. See the README.md files in the the directory that you are referencing for further information.

## Inputs and Outputs

### Inputs

- `platform`
  - A string that contains the platform that is being used. Allowed values are either `javascript-nextjs` or `node-express`.
- `name_parts`
  - An object containing two strings. The `git_repo` and the `suffix`.
- `sentry_organization_slug`
  - A string containing the organisation to use within Sentry.
- `sentry_team_slug`
  - A string containing the team to assign the project to within Sentry.
    - An outstanding improvement point here is to make this a list, so you can specify more than one team.

### Outputs

- `sentry_dsn`
  - The DSN that is generated at creation time.
- `project_slug`
  - The slug for the project to look up the current DSN if needed.

## Using `sentry_project` module

The `sentry_project` module is used in one place specifically, but can also be used directly to loop in a Sentry project into IaC.

### `vercel_project`

In the `vercel_project` Terraform module, Sentry is managed internally and is created alongside the Vercel project itself. It will add two additional environment variables:

- `SENTRY_DSN` which is the ingestion point for data created by your Vercel project.
- `SENTRY_ENVIRONMENT` is a duplicate of the standard `env`.

### `gcp_api`

In the `gcp_api` Terraform module, Sentry is managed externally and **must** be created first (in it's own [Terraform Workspace](https://developer.hashicorp.com/terraform/cloud-docs/workspaces)) so that it can be then used for subsequent environments.

API projects should typically use the [Official Sentry SDK for Node](https://github.com/getsentry/sentry-javascript/tree/master/packages/node) to interact with the service.

### Directly

To use the module directly, there are a few steps to be aware of:

1. Use the module in it's own workspace
   - The `sentry_project` module has two outputs, you're going to need these to either:
      - freshly get the DSN
      - use the cached one from creation time.
2. Ensure that the variables outlined in the [Inputs](#inputs) section above are included.
3. Ensure that the output variables are provided by the workspace:

```hcl
output "sentry_dsn" {
  description = "The DSN for the Sentry project."
  value       = module.sentry.sentry_dsn
  sensitive   = true
}

output "sentry_project_slug" {
  description = "The slug of the Sentry project, for downstream workspaces to look up its DSN."
  value       = module.sentry.sentry_project_slug
}
```

## Using Sentry

It is recommended to use the [Official Sentry SDK](https://github.com/getsentry/sentry-javascript) for interacting with your Sentry project.
