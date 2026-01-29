terraform {
  required_version = ">= 1.5.7"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.6.0"
    }

    vercel = {
      source  = "vercel/vercel"
      version = "~> 3.14.1"
    }
  }
}

provider "vercel" {
  team = "oak-national-academy"
}