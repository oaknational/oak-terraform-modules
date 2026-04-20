variable "platform" {
  description = "The platform for the Sentry project."
  type        = string

  validation {
    condition     = contains(["javascript-nextjs", "node-express"], var.platform)
    error_message = "Platform must be one of: javascript-nextjs, node-express."
  }
}

variable "repo_name" {
  description = "The name of the Sentry project.This should be the repo name."
  type        = string
}

variable "sentry_organization_slug" {
  description = "The slug of the Sentry organization."
  type        = string
}

variable "sentry_team_slug" {
  description = "The slug of the Sentry team."
  type        = string
}
