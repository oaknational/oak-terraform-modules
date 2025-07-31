variable "region" {
  description = "The Google Cloud region to deploy in (use Google Cloud names)"
  type        = string
  nullable    = false
  default     = "europe-west2"
}

variable "service_account_email" {
  description = "The email of a service account that can run this function"
  type        = string
}

variable "env" {
  description = "The environment name"
  type        = string
}

variable "tag_id" {
  description = "The tag id of the docker image"
  type        = string
  nullable    = false
}
