resource "azapi_resource" "network_rule_set" {
  type      = "Microsoft.Relay/namespaces/networkRuleSets@2024-01-01"
  name      = "default"
  parent_id = var.relay_namespace_id

  body = {
    properties = {
      defaultAction              = var.default_action
      publicNetworkAccess        = var.public_network_access
      ipRules                    = var.ip_rules
      trustedServiceAccessEnabled = var.trusted_service_access_enabled
    }
  }
}
