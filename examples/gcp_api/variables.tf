variable "cloudflare_account_name" {
  description = "The name of the Cloudflare account"
  type        = string
  nullable    = false
}

variable "cloudflare_zone_domain" {
  description = "The domain to use for the api endpoint"
  type        = string
  nullable    = false
}

variable "region" {
  description = "The Google Cloud region to deploy in (use Google Cloud names)"
  type        = string
  nullable    = false
  default     = "europe-west2"
}

variable "source_bucket" {
  description = "The storage bucket where the source code is"
  type        = string
}

variable "service_account_email" {
  description = "The email of a service account that can run this function"
  type        = string
}

variable "env" {
  description = "The environment name"
  type        = string
}

variable "config_version" {
  description = "For each new version of the openapi config this version needs to be advanced"
  type        = number
  default     = 2
}

