output "name" {
  description = "The name of the Azure Relay Namespace."
  value       = azapi_resource.relay_namespace.name
}

output "primary_connection_string" {
  description = "The primary connection string for the Azure Relay Namespace."
  sensitive   = true
  value       = try(jsondecode(azapi_resource.relay_namespace.output).properties.primaryConnectionString, null)
}

output "private_endpoints" {
  description = "A map of the private endpoints created."
  value       = azapi_resource.private_endpoints
}

output "resource_group_name" {
  description = "The name of the resource group in which the Azure Relay Namespace is created."
  value       = var.resource_group_name
}

output "resource_id" {
  description = "The ID of the Azure Relay Namespace."
  value       = azapi_resource.relay_namespace.id
}

output "secondary_connection_string" {
  description = "The secondary connection string for the Azure Relay Namespace."
  sensitive   = true
  value       = try(jsondecode(azapi_resource.relay_namespace.output).properties.secondaryConnectionString, null)
}

output "system_assigned_managed_identity" {
  description = "The system assigned managed identity assigned to the Azure Relay Namespace."
  value       = try(jsondecode(azapi_resource.relay_namespace.output).identity.principalId, null)
}
