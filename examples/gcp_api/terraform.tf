terraform {
  required_version = ">= 1.9.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.29.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.19.0"
    }
  }
}
