resource "azapi_resource" "hybrid_connection" {
  type      = "Microsoft.Relay/namespaces/hybridConnections@2024-01-01"
  name      = var.name
  parent_id = var.relay_namespace_id

  body = {
    properties = {
      requiresClientAuthorization = var.requires_client_authorization
      userMetadata                = var.user_metadata
    }
  }
}
