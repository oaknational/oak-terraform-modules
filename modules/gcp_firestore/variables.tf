variable "name_parts" {
  description = "The parts of the name, see the naming convention doc for more information"
  type = object({
    domain   = string
    region   = optional(string, "ldn")
    app      = string
    resource = string
  })
  nullable = false

  validation {
    condition     = length(var.name_parts.domain) == 2
    error_message = "Domain part of the name should be 2 chars"
  }

  validation {
    condition     = length(var.name_parts.region) == 3
    error_message = "Region part of the name should be 3 chars"
  }

  validation {
    condition     = can(regex("^[a-z]+$", var.name_parts.app))
    error_message = "App part of the name should only contain lower case letters"
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

variable "region" {
  description = "The Google Cloud region name"
  type        = string
  nullable    = false
  default     = "europe-west2"
}

variable "indexes" {
  description = <<EOD
    Data indexes to be added to Firestore

    collection = the Firestore connection

    fields
      path = the name of the field (sometimes referred to field_path)
      asc  = the sort order for the field, defaults to ascending, set to false for descending

    If no __name__ field is added __name__ ascending will be added by default
  EOD
  type = list(object({
    collection = string
    fields = list(object({
      path = string
      asc  = optional(bool, true)
    }))
  }))
  default = []

  validation {
    condition     = alltrue([for i in var.indexes : length(i) != 1])
    error_message = "Indexes should not contain only 1 field"
  }
}

variable "enable_point_in_time_recovery" {
  description = "Whether or not to enable point in time recovery on the Firestore datastore"
  type        = bool
  default     = false
}

variable "use_optimistic_concurrency" {
  description = <<EOD
    Optimistic concurreny means data locking isn't used when updating records,
    it is faster but risks data loss.

    Only use optimistic concurrency for write once/never update data.
  EOD
  type        = bool
  default     = false
}
