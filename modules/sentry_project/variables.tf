variable "platform" {
  description = "The platform for the Sentry project."
  type        = string

  validation {
    condition     = contains(["javascript-nextjs", "node-express"], var.platform)
    error_message = "Platform must be one of: javascript-nextjs, node-express."
  }
}

variable "name_parts" {
  description = "The parts that make up the name. By convention this is the Git repo name and a suffix"
  type = object({
    git_repo = string
    suffix   = string
  })
}

variable "sentry_organization_slug" {
  description = "The slug of the Sentry organization."
  type        = string
}

variable "sentry_team_slug" {
  description = "The slug of the Sentry team."
  type        = string
}
