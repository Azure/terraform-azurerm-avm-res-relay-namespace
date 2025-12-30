resource "azapi_resource" "authorization_rule" {
  type      = "Microsoft.Relay/namespaces/authorizationRules@2024-01-01"
  name      = var.name
  parent_id = var.relay_namespace_id

  body = {
    properties = {
      rights = var.rights
    }
  }
}
