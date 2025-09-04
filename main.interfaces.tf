module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.5.0"

  # Diagnostic Settings interface
  diagnostic_settings = var.diagnostic_settings
  # Enable telemetry
  enable_telemetry = var.enable_telemetry
  # Lock interface
  lock = var.lock
  # Private endpoints interface
  private_endpoints                         = var.private_endpoints
  private_endpoints_manage_dns_zone_group   = var.private_endpoints_manage_dns_zone_group
  private_endpoints_scope                   = azapi_resource.relay_namespace.id
  role_assignment_definition_lookup_enabled = true
  role_assignment_definition_scope          = local.subscription_resource_id
  role_assignment_name_use_random_uuid      = true
  # Role assignments interface
  role_assignments = var.role_assignments
}
