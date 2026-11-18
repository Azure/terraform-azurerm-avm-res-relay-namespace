resource "azapi_update_resource" "authorization_rule" {
  resource_id = "${var.relay_namespace_id}/authorizationRules/${var.name}"
  type        = var.resource_types.relay_namespaces_authorization_rules
  body = {
    properties = {
      rights = sort(var.rights)
    }
  }
  response_export_values = null
  retry                  = var.retry

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
