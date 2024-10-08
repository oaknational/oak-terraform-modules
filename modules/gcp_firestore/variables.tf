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

variable "backup" {
  description = <<EOD
    Configure the backup/data recovery options:

    frequency     = [d]aily [w]eekly or [n]ever
    retention     = number of days to retain the backup data for
    point_in_time = enable point in time recovery
    day           = 0-6 the day of the week to do backups (0 = Sunday, 6 = Saturday)

    To skip all backups set `backup = { frequency = "n" }`
  EOD

  type = object({
    frequency     = string
    retention     = optional(number, 0)
    point_in_time = optional(bool, false)
    day           = optional(number)
  })

  validation {
    condition     = contains(["d", "w", "n"], var.backup.frequency)
    error_message = "Frequency should be either [d]aily, [w]eekly or [n]ever"
  }

  validation {
    condition = (
      var.backup.frequency == "n"
      ||
      (contains(["d", "w"], coalesce(var.backup.frequency, "null")) && var.backup.retention > 0)
    )
    error_message = "If enabling backups specify retention > 0"
  }

  validation {
    condition = (
      var.backup.frequency != "n"
      ||
      (var.backup.frequency == "n" && var.backup.retention == 0)
    )
    error_message = "Retention not valid if frequency is never"
  }

  validation {
    condition = (
      (var.backup.frequency != "w" && coalesce(var.backup.day, 99) == 99)
      ||
      (var.backup.frequency == "w" && coalesce(var.backup.day, 99) != 99)
    )
    error_message = "Backup day only valid for weekly backups"
  }

  validation {
    condition = (
      var.backup.frequency != "w"
      ||
      (var.backup.frequency == "w" && (coalesce(var.backup.day, 99) >= 0 && coalesce(var.backup.day, 99) <= 6))
    )
    error_message = "Weekly backup day should be between 0 and 6 for weekly backups"
  }
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
