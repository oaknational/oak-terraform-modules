variable "build_command" {
  description = "The build command for the project"
  type        = string
  default     = null
}

variable "build_machine_type" {
  description = <<-EOT
  The build machine type for the project. Acceptable values are "standard", "enhanced", or "turbo".
  Note: It is not backward-compatible. Once it is set to "enhanced" or "turbo", it can't be reverted to "standard" using Terraform as
  the Vercel provider only supports "enhanced" and "turbo" values.
  EOT

  type    = string
  default = "standard"

  validation {
    condition     = contains(["standard", "enhanced", "turbo"], var.build_machine_type)
    error_message = "Build machine type must be one of: standard, enhanced, turbo. "
  }
}

variable "build_type" {
  description = "Suffix to append to vercel project name (e.g. 'website', 'storybook')"
  type        = string

  validation {
    condition     = can(regex("^[a-z-]+$", var.build_type))
    error_message = "Build type may only contain lowercase letters and hyphens (no digits, spaces, or other symbols)."
  }
}

variable "detectify_bypass_domain" {
  type        = string
  default     = null
  description = "The domain to bypass the firewall for Detectify scans."
}

variable "custom_environments" {
  description = "Custom environments"

  type = list(object({
    name        = string
    domain      = string
    branch_name = optional(string)
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
    sensitive               = optional(bool, false)
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

variable "expose_system_variables" {
  type    = bool
  default = true
}

variable "framework" {
  description = <<-EOT
    The framework preset used for the project. Acceptable values are "nextjs", "storybook", or "other".
    Note: Use "other" when your project doesn't use a specific framework preset.
    This allows Vercel to auto-detect the framework or use no preset at all.
  EOT
  type        = string
  default     = "nextjs"

  validation {
    condition     = contains(["nextjs", "storybook", "other"], var.framework)
    error_message = "Framework must be one of: nextjs, storybook, other."
  }
}

variable "git_branch" {
  description = "Git branch to link to the project domain"
  type        = string
  default     = null
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

variable "options_allowlist_paths" {
  description = "List of paths to disable Deployment Protection for CORS preflight OPTIONS requests."
  type        = list(string)
  default     = null

  validation {
    condition = var.options_allowlist_paths == null ? true : alltrue([
      for path in var.options_allowlist_paths : startswith(path, "/")
    ])
    error_message = "Paths must start with '/'."
  }
}

variable "production_branch" {
  description = "Branch name that triggers production deploys"
  type        = string
  default     = "main"
}

variable "project_visibility" {
  description = "Can be either private (all domains are behind login) or public (custom domains are publicly available)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public"], var.project_visibility)
    error_message = "Project visibility must be either 'private' or 'public'."
  }
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
