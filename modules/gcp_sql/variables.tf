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

variable "memory" {
  description = "The size (in memory capacity) of the instance"
  type        = number
  nullable    = false

  validation {
    condition     = contains([0.6, 1.7, 3.7, 8, 16], var.memory)
    error_message = "Invalid memory set. Only valid values are: 0.6, 1.7, 3.7, 8, 16"
  }
}

variable "authorized_networks" {
  description = "Allowable IP ranges for connectivity"
  type = list(object({
    description = string
    cidr        = string
  }))
  default = []

  validation {
    condition     = alltrue([for an in var.authorized_networks : can(cidrnetmask(an.cidr))])
    error_message = "Invalid cidr found"
  }
}

variable "vpc_network_link" {
  description = "The resource name of the VPC e.g. projects/{project}/global/networks/{vpc_name}"
  type        = string
  nullable    = false
}

variable "deletion_protection" {
  description = "While set to true the instance cannot be deleted"
  type        = bool
  nullable    = false
  default     = true
}

variable "high_availability" {
  description = "Enable high availability for the instance"
  type        = bool
  default     = false
}