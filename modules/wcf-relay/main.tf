resource "azapi_resource" "wcf_relay" {
  name      = var.name
  parent_id = var.relay_namespace_id
  type      = var.resource_types.relay_namespaces_wcf_relays
  body = {
    properties = {
      relayType                   = var.relay_type
      requiresClientAuthorization = var.requires_client_authorization
      requiresTransportSecurity   = var.requires_transport_security
      userMetadata                = var.user_metadata
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.relay_namespaces_wcf_relays) > 0 ? var.ignore_body_changes.relay_namespaces_wcf_relays : null
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
