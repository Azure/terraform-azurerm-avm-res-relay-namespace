resource "azapi_update_resource" "network_rule_set" {
  resource_id = "${var.relay_namespace_id}/networkRuleSets/default"
  type        = "Microsoft.Relay/namespaces/networkRuleSets@2024-01-01"
  body = {
    properties = {
      defaultAction               = var.default_action
      publicNetworkAccess         = var.public_network_access
      ipRules                     = var.ip_rules
      trustedServiceAccessEnabled = var.trusted_service_access_enabled
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
}
