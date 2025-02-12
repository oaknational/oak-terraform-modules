terraform {

  required_version = ">= 1.9.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }
  }
}
