terraform {
  required_version = ">= 1.5.7"

  required_providers {
    sentry = {
      source  = "jianyuan/sentry"
      version = "0.15.0-beta1"
    }
  }
}
