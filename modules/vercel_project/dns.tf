data "cloudflare_zone" "this" {
  filter = {
    name = var.cloudflare_zone_domain
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = { for domain in local.all_domains : domain.name => domain }

  zone_id = data.cloudflare_zone.this.zone_id
  name    = replace(each.value.name, "/\\.?${var.cloudflare_zone_domain}$/", "")
  type    = "CNAME"
  content = "cname.vercel-dns.com"
  proxied = true
  ttl     = 1
}