variable "name_parts" {
  description = "The parts of the name, see the naming convention doc for more information"
  type = object({
    domain = string
    region = optional(string, "ldn")
    app    = string
  })
  nullable = false

  validation {
    condition     = can(regex("^[a-z]{2}$", var.name_parts.domain))
    error_message = "Domain part of the name should be exactly 2 lowercase chars"
  }

  validation {
    condition     = can(regex("^[a-z]{3}$", var.name_parts.region))
    error_message = "Region part of the name should be exactly 3 lowercase chars"
  }

  validation {
    condition     = can(regex("^[a-z-]+$", join("-", values(var.name_parts))))
    error_message = "Name parts should only contain lowercase letters or -"
  }
}

variable "env" {
  description = "The environment"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]+$", var.env))
    error_message = "Env should only contain lower case letters"
  }
}

variable "docker_image" {
  description = "The id of the docker image to deploy"
  type        = string
  nullable    = false
}

variable "google_cloud_region" {
  description = "The Google Cloud region to deploy in (use Google Cloud names)"
  type        = string
  nullable    = false
  default     = "europe-west2"
}

variable "environment_variables" {
  description = "Environment variables for the job"
  type = list(object({
    name  = string
    value = string
  }))
  nullable = false
  default  = []
}

variable "service_account_email" {
  description = "The email of the service account to use when running the job"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z-]+@[a-z-]+.iam.gserviceaccount.com$", var.service_account_email))
    error_message = "Service account is not a valid GCP account"
  }
}

variable "schedule" {
  description = "A list of crons formatted times to schedule a job execution"
  type = object({
    crons     = list(string)
    time_zone = optional(string, "Europe/London")
  })
  nullable = true
  default  = null

  validation {
    condition = alltrue([
      for c in try(var.schedule.crons, []) : can(
        regex("^[\\d\\*]{1,2} [\\d\\*]{1,2} [\\d\\*]{1,2} [\\d\\*]{1,2} [\\d\\*]$", c)
      )
    ])
    error_message = "Invalid formatted cron"
  }
}
