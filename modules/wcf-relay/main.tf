resource "azapi_resource" "wcf_relay" {
  type      = "Microsoft.Relay/namespaces/wcfRelays@2024-01-01"
  name      = var.name
  parent_id = var.relay_namespace_id

  body = {
    properties = {
      relayType                   = var.relay_type
      requiresClientAuthorization = var.requires_client_authorization
      requiresTransportSecurity   = var.requires_transport_security
      userMetadata                = var.user_metadata
    }
  }
}
