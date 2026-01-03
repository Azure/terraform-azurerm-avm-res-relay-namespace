resource "azapi_update_resource" "authorization_rule" {
  resource_id = "${var.relay_namespace_id}/authorizationRules/${var.name}"
  type        = "Microsoft.Relay/namespaces/authorizationRules@2024-01-01"
  body = {
    properties = {
      rights = sort(var.rights)
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null

  lifecycle {
    ignore_changes = [
      body.properties.rights,
    ]
  }
}
