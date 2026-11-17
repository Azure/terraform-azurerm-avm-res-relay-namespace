resource "azapi_update_resource" "network_rule_set" {
  resource_id = "${var.relay_namespace_id}/networkRuleSets/default"
  type        = var.resource_types.relay_namespaces_network_rule_sets
  body = {
    properties = {
      defaultAction               = var.default_action
      publicNetworkAccess         = var.public_network_access
      ipRules                     = var.ip_rules
      trustedServiceAccessEnabled = var.trusted_service_access_enabled
    }
  }
  read_headers           = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  response_export_values = null
  retry                  = var.retry
  update_headers         = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
