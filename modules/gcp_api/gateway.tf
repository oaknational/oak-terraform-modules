locals {
  gateway_template_map = {
    for e in var.gateway.entrypoint_map : e.variable => google_cloudfunctions2_function.this[e.entrypoint].url
  }
}

resource "google_api_gateway_api" "this" {
  provider = google-beta

  api_id = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}-api"
}

resource "google_api_gateway_api_config" "this" {
  provider = google-beta

  api           = google_api_gateway_api.this.api_id
  api_config_id = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}-api-v${var.gateway.config_version}"

  openapi_documents {
    document {
      path = "openapi.yaml"
      contents = base64encode(
        templatefile(var.gateway.config_file, local.gateway_template_map)
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "this" {
  provider = google-beta

  region = var.google_cloud_region

  api_config = google_api_gateway_api_config.this.id
  gateway_id = "${var.name_parts.domain}-${var.env}-${var.name_parts.region}-${var.name_parts.app}-api"
}
