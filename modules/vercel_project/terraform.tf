terraform {
  required_version = ">= 1.5.7"

  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 3.5.1"
    }
  }
}

provider "vercel" {
  team = "oak-national-academy"
}