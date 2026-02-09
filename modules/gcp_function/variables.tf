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

variable "function" {
  description = <<EOD
    A definition for a single function:

    entrypoint              = The name of the function to execute
    runtime                 = A valid GCP runtime. See `gcloud functions runtimes list` for a full list
    source_object           = The path and object name of the source file stored in the function_source_bucket
    available_memory_pwr    = The memory allocation calculated as 2^x * 128 in MB (or MiB, Google is not clear)
        0 = 128 MB
        1	= 256 MB
        2	= 512 MB
        3	= 1 GB
        4	= 2 GB
        5	= 4 GB
        6	= 8 GB
        7	= 16 GB
        8	= 32 GB

    available_cpu           = The number of CPUs assigned to the function. If missed or 0 calculates based on memory allocation
    timeout_seconds         = Number of maxiumum number of seconds to run before the function is cancelled
    max_instance_count      = The max number of instances to scale to (1 to turn off auto scaling)
    max_request_concurrency = The max number of requests a single instance should handle
    service_account_email   = The email address to use for granting 
    
    environment_variables
      name  = The name of the environment variable
      value = The value of the environment variable
  EOD
  type = object({
    entrypoint              = string
    runtime                 = string
    source_object           = string
    available_memory_pwr    = optional(number, 1)
    available_cpu           = optional(number, 0)
    timeout_seconds         = optional(number, 60)
    max_instance_count      = optional(number, 1)
    max_request_concurrency = optional(number, 1)
    service_account_email   = string
    environment_variables = list(object({
      name  = string
      value = string
    }))
  })

  validation {
    condition     = var.function.available_memory_pwr >= 0 && var.function.available_memory_pwr <= 8
    error_message = "available_memory_pwr must be a number between 0 and 8"
  }

  validation {
    condition     = var.function.timeout_seconds > 0 && var.function.timeout_seconds <= 3600
    error_message = "Timeout should be a positive integer no greater than 3600"
  }

  validation {
    condition     = var.function.max_instance_count > 0
    error_message = "max_instance_count must be at least 1"
  }

  validation {
    condition     = var.function.max_request_concurrency > 0
    error_message = "max_request_concurrency must be at least 1"
  }

  validation {
    condition = var.function.max_request_concurrency == 1 || (
      var.function.max_request_concurrency > 1 && (
        # If using the default cpu setting memory_pwr 4 (2GB) allocates a full CPU core
        var.function.available_cpu >= 1 || (var.function.available_cpu == 0 && var.function.available_memory_pwr > 4)
      )
    )
    error_message = "CPU must be 1 or greater to enable multiple concurrency"
  }
}
