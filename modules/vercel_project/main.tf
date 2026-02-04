locals {
  repo_only = split("/", var.git_repo)[1]

  normalized_repo = lower(replace(local.repo_only, "_", "-"))

  project_name = "${local.normalized_repo}-${var.build_type}"

  deployment_type = var.project_visibility == "private" ? "all_deployments" : "standard_protection_new"

  #converts standard to null as it's the default value in Vercel API
  build_machine_type_to_use = var.build_machine_type == "standard" ? null : var.build_machine_type

  framework = var.framework == "other" ? null : var.framework

  all_domains = concat(
    [for domain in var.domains : { name = domain }],
    [for ce in var.custom_environments : {
      name                    = ce.domain
      custom_environment_name = ce.name
    }]
  )

  custom_env_vars = [
    for cev in var.custom_env_vars : merge(cev,
      { custom_environment_ids = [
        vercel_custom_environment.this[cev.custom_environment_name].id
    ] })
  ]

  all_env_vars = concat(var.environment_variables, local.custom_env_vars)

  detectify_ips = ["52.17.9.21", "52.17.98.131"]

  bypass_rules = var.detectify_bypass_domain != null ? [
    for ip in local.detectify_ips : {
      domain    = var.detectify_bypass_domain
      source_ip = ip
    }
  ] : []

  options_allowlist_obj = var.options_allowlist_paths == null ? null : {
    paths = [for p in var.options_allowlist_paths : { value = p }]
  }
}

resource "vercel_project" "this" {
  name                                              = local.project_name
  automatically_expose_system_environment_variables = var.expose_system_variables
  framework                                         = local.framework
  build_command                                     = var.build_command
  ignore_command                                    = var.ignore_command
  install_command                                   = var.install_command
  skew_protection                                   = var.skew_protection
  prioritise_production_builds                      = true
  protection_bypass_for_automation                  = var.protection_bypass_for_automation
  options_allowlist                                 = local.options_allowlist_obj
  output_directory                                  = var.output_directory
  build_machine_type                                = local.build_machine_type_to_use

  vercel_authentication = {
    deployment_type = local.deployment_type
  }

  root_directory = var.root_directory
  git_repository = {
    type              = "github"
    repo              = var.git_repo
    production_branch = var.production_branch
  }
}

resource "vercel_project_domain" "this" {
  for_each = { for domain in local.all_domains : domain.name => domain }

  project_id            = vercel_project.this.id
  domain                = each.key
  custom_environment_id = try(vercel_custom_environment.this[each.value.custom_environment_name].id, null)
  git_branch            = var.git_branch
}

resource "vercel_project_environment_variables" "this" {
  count = length(local.all_env_vars) > 0 ? 1 : 0

  project_id = vercel_project.this.id
  variables = [
    for ev in local.all_env_vars : {
      key                    = ev.key
      value                  = ev.value
      sensitive              = ev.sensitive
      target                 = try(ev.target, null)
      custom_environment_ids = try(ev.custom_environment_ids, null)
    }
  ]
}

resource "vercel_deployment" "this" {
  depends_on = [vercel_project_environment_variables.this]

  project_id = vercel_project.this.id
  ref        = var.production_branch
  production = false
}

resource "vercel_custom_environment" "this" {
  for_each    = { for env in var.custom_environments : env.name => env }
  project_id  = vercel_project.this.id
  name        = each.value.name
  description = "Custom environment for ${each.value.name}"

  branch_tracking = {
    pattern = each.value.branch_name != null ? each.value.branch_name : each.value.name
    type    = "equals"
  }
}

resource "vercel_firewall_bypass" "this" {
  for_each = { for rule in local.bypass_rules : "${rule.domain}-${rule.source_ip}" => rule }

  project_id = vercel_project.this.id
  source_ip  = each.value.source_ip
  domain     = each.value.domain
}

resource "vercel_project_deployment_retention" "this" {
  project_id            = vercel_project.this.id
  expiration_preview    = "1m"
  expiration_production = "1m"
  expiration_canceled   = "1m"
  expiration_errored    = "1m"
}
