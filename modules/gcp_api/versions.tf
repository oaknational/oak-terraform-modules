terraform {
  required_version = ">= 1.5.7"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.29.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "5.2.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.77.0"
    }
  }
}
