resource "azapi_resource" "authorization_rule" {
  type      = "Microsoft.Relay/namespaces/authorizationRules@2024-01-01"
  name      = var.name
  parent_id = var.relay_namespace_id

  body = {
    properties = {
      rights = var.rights
    }
  }

  create_headers = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
}
