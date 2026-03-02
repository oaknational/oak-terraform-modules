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

variable "description" {
  description = "A free text description of the function"
  type        = string
  nullable    = false
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

variable "google_cloud_region" {
  description = "The Google Cloud region to deploy in (use Google Cloud names)"
  type        = string
  nullable    = false
  default     = "europe-west2"
}

variable "function_source_bucket" {
  description = "The bucket where the source file is uploaded"
  type        = string
  nullable    = false
}

variable "entrypoint" {
  description = "The name of the function to execute"
  type        = string
  nullable    = false
}

variable "runtime" {
  description = "A valid GCP runtime. See `gcloud functions runtimes list` for a full list"
  type        = string
  nullable    = false
}

variable "source_object" {
  description = "The path and object name of the source file stored in the function_source_bucket"
  type        = string
  nullable    = false
}

variable "available_memory_pwr" {
  description = "The memory allocation calculated as 2^x * 128 in MB (0=128MB, 1=256MB, ..., 8=32GB)"
  type        = number
  default     = 1
  validation {
    condition     = var.available_memory_pwr >= 0 && var.available_memory_pwr <= 8
    error_message = "available_memory_pwr must be a number between 0 and 8"
  }
}

variable "available_cpu" {
  description = "The number of CPUs assigned to the function. If 0, calculates based on memory allocation"
  type        = number
  default     = 0
}

variable "timeout_seconds" {
  description = "Maximum number of seconds to run before the function is cancelled"
  type        = number
  default     = 60
  validation {
    condition     = var.timeout_seconds > 0 && var.timeout_seconds <= 3600
    error_message = "Timeout should be a positive integer no greater than 3600"
  }
}

variable "max_instance_count" {
  description = "The max number of instances to scale to (1 to turn off auto scaling)"
  type        = number
  default     = 1
  validation {
    condition     = var.max_instance_count > 0
    error_message = "max_instance_count must be at least 1"
  }
}

variable "max_request_concurrency" {
  description = "The max number of requests a single instance should handle"
  type        = number
  default     = 1
  validation {
    condition     = var.max_request_concurrency > 0
    error_message = "max_request_concurrency must be at least 1"
  }
  validation {
    condition = var.max_request_concurrency == 1 || (
      var.max_request_concurrency > 1 && (
        # If using the default cpu setting memory_pwr 4 (2GB) allocates a full CPU core
        var.available_cpu >= 1 || (var.available_cpu == 0 && var.available_memory_pwr > 4)
      )
    )
    error_message = "CPU must be 1 or greater to enable multiple concurrency"
  }
}

variable "service_account_email" {
  description = "The email address to use for granting permissions"
  type        = string
  nullable    = false
}

variable "environment_variables" {
  description = "List of environment variables for the function"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets to be injected as environment variables"
  type = list(object({
    env_name    = string
    secret_name = string
  }))
  default = []
}
