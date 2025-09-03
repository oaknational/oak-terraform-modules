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

variable "cpu_allocation" {
  description = "The number of vCPUs allocated to the job (1, 2, 4, 6, or 8)"
  type        = number
  nullable    = false
  default     = 1

  validation {
    condition     = contains([1, 2, 4, 6, 8], var.cpu_allocation)
    error_message = "CPU allocation must be one of: 1, 2, 4, 6, 8."
  }
}

variable "memory_allocation" {
  description = "Memory allocation in Gi (0.5 or whole numbers between 1-32)"
  type        = number
  nullable    = false
  default     = 1

  validation {
    condition = (
      (var.memory_allocation == 0.5 ||
        (var.memory_allocation >= 1 &&
          var.memory_allocation <= 32 &&
      floor(var.memory_allocation) == var.memory_allocation))
    )
    error_message = "Memory allocation must be 0.5 or whole numbers between 1-32"
  }

  validation {
    condition = (
      (var.memory_allocation < 4 || var.cpu_allocation >= 2) &&
      (var.memory_allocation < 8 || var.cpu_allocation >= 4) &&
      (var.memory_allocation < 16 || var.cpu_allocation >= 6) &&
      (var.memory_allocation < 24 || var.cpu_allocation >= 8)
    )
    error_message = <<-EOT
    Memory allocation must respect CPU requirements:
    More than 4 GiB needs 2vCPU,
    More than 8 GiB needs 4vCPU,
    More than 16 GiB needs 6vCPU,
    More than 24 GiB needs 8vCPU.
    EOT
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

variable "job_service_account_email" {
  description = "The email of the service account used to run the Cloud Run job"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z-]+@[a-z-]+.iam.gserviceaccount.com$", var.job_service_account_email))
    error_message = "Service account is not a valid GCP account"
  }
}

variable "scheduler_service_account_email" {
  description = "The email of the service account used by Cloud Scheduler to authenticate and invoke the job"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z-]+@[a-z-]+.iam.gserviceaccount.com$", var.scheduler_service_account_email))
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
