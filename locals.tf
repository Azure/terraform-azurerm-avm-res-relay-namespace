locals {
  # Managed identity configuration
  # This local transforms the input variable into the format required by azapi_resource
  # It creates conditional maps that are used by dynamic blocks in the resource definition
  managed_identities = {
    # Combined system and user assigned identities
    # Used when both types are configured or when only one type is needed
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    # System assigned identity only
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    # User assigned identities only
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
  # Map private endpoints to pass to the AVM utility module
  private_endpoints = var.private_endpoints

  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
