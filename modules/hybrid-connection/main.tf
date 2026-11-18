resource "azapi_resource" "hybrid_connection" {
  name      = var.name
  parent_id = var.relay_namespace_id
  type      = var.resource_types.relay_namespaces_hybrid_connections
  body = {
    properties = {
      requiresClientAuthorization = var.requires_client_authorization
      userMetadata                = var.user_metadata
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.relay_namespaces_hybrid_connections) > 0 ? var.ignore_body_changes.relay_namespaces_hybrid_connections : null
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
