locals {
  # Map private endpoints to pass to the AVM utility module
  private_endpoints                  = var.private_endpoints
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
