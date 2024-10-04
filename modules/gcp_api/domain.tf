data "cloudflare_accounts" "this" {
  name = var.cloudflare_account_name
}

data "cloudflare_zone" "this" {
  account_id = data.cloudflare_accounts.this.accounts[0].id
  name       = var.cloudflare_zone_domain
}

locals {
  public_domain_name = join("-", compact([var.sub_domain, var.env == "prod" ? null : var.env]))
}

resource "cloudflare_record" "cname" {
  zone_id = data.cloudflare_zone.this.id
  name    = local.public_domain_name
  type    = "CNAME"
  value   = google_api_gateway_gateway.this.default_hostname
  ttl     = 1
  proxied = true
}

resource "cloudflare_page_rule" "this" {
  zone_id = data.cloudflare_zone.this.id
  target  = "${local.public_domain_name}.${data.cloudflare_zone.this.name}/*"

  # Priority will never be this value but by setting it high it won't interfere with the values
  # in the cloudflare-page-rules workspace (See that config for a more detailed explanation).
  priority = 999

  # The 999 priority will be reduced to a lower value by Cloudflare
  lifecycle {
    ignore_changes = [
      priority,
    ]
  }

  actions {
    host_header_override = google_api_gateway_gateway.this.default_hostname
  }
}
