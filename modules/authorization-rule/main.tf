resource "azapi_update_resource" "authorization_rule" {
  resource_id = "${var.relay_namespace_id}/authorizationRules/${var.name}"
  type        = var.resource_types.relay_namespaces_authorization_rules
  body = {
    properties = {
      rights = sort(var.rights)
    }
  }
  read_headers           = var.enable_telemetry ? { "User-Agent" : var.avm_azapi_header } : null
  response_export_values = []
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
