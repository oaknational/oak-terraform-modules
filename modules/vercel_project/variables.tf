variable "build_command" {
  description = "The build command for the project"
  type        = string
  default     = null
}

variable "build_type" {
  description = "Suffix to append to vercel project name (e.g. 'website', 'storybook')"
  type        = string

  validation {
    condition     = can(regex("^[a-z-]+$", var.build_type))
    error_message = "Build type may only contain lowercase letters and hyphens (no digits, spaces, or other symbols)."
  }
}

variable "custom_environments" {
  description = "Custom environments"

  type = list(object({
    name   = string
    domain = string
  }))
  default = []

  validation {
    condition = alltrue([
      for env in var.custom_environments : can(regex("${var.cloudflare_zone_domain}$", env.domain))
    ])
    error_message = <<-EOT
      Domain must end with '${var.cloudflare_zone_domain}'
      Invalid domain(s):${join(",", [for env in var.custom_environments : "'${env.domain}'"])}
      EOT
  }
}

variable "custom_env_vars" {
  description = "Custom environment environment variables"
  type = list(object({
    key                     = string
    value                   = string
    custom_environment_name = string
  }))
  default = []
  validation {
    condition = alltrue([
      for cev in var.custom_env_vars :
      contains([for ce in var.custom_environments : ce.name], cev.custom_environment_name)
    ])
    error_message = <<-EOT
        Invalid environment name in custom_env_vars, custom environment name values must match existing custom environment names.
        
        Available environments: ${join(", ", [for ce in var.custom_environments : ce.name])}
        Invalid references found in custom_env_vars: ${join(", ", distinct([for cev in var.custom_env_vars : cev.custom_environment_name if !contains([for ce in var.custom_environments : ce.name], cev.custom_environment_name)]))}

EOT
  }
}

variable "deployment_type" {
  description = "The deployment environment to protect."
  type        = string
}

variable "domains" {
  description = "Custom domains"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for domain in var.domains :
      can(regex("${var.cloudflare_zone_domain}$", domain))
    ])
    error_message = <<-EOT
      Domain must end with '${var.cloudflare_zone_domain}'
      Invalid domain(s):${join(",", [for domain in var.domains : "'${domain}'"])}
      EOT
  }
}

variable "environment_variables" {
  description = <<-EOT
    List of environment variable objects.
    Each object must have:
      - key       (string): the env var name
      - value     (string): the env var value
      - target   (list(string)): which Vercel targets (e.g. ["preview"], ["production","preview"])
      - sensitive (bool): whether to treat as a secret
  EOT
  type = list(object({
    key       = string
    value     = string
    target    = list(string)
    sensitive = optional(bool, false)
  }))
  default = []
}

variable "framework" {
  description = "Framework for the project (e.g. nextjs, nodejs)"
  type        = string
  default     = "nextjs"
}

variable "git_repo" {
  description = "Git repository URL"
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.git_repo))
    error_message = "The git_repo must be in the format 'owner/repository' (e.g., 'oaknational/Oak-Web-Application')."
  }
}

variable "ignore_command" {
  description = "Command to determine if build should be skipped"
  type        = string
  default     = null
}

variable "install_command" {
  description = "The install command for the project"
  type        = string
  default     = null
}

variable "production_branch" {
  description = "Branch name that triggers production deploys"
  type        = string
  default     = "main"
}

variable "protection_bypass_for_automation" {
  description = "Allow automation services to bypass Deployment Protection"
  type        = bool
  default     = true
}

variable "output_directory" {
  description = "The output directory of the project"
  type        = string
  default     = null
}

variable "root_directory" {
  description = "Path to project root within the repo"
  type        = string
  default     = null
}

variable "skew_protection" {
  description = "Defines how long Vercel keeps Skew Protection active"
  type        = string
  default     = null
}

variable "cloudflare_zone_domain" {
  description = "Domain name for the zone"
  type        = string
}