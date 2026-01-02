output "name" {
  description = "The name of the hybrid connection."
  value       = azapi_resource.hybrid_connection.name
}

output "resource" {
  description = "The full resource object of the hybrid connection."
  value       = azapi_resource.hybrid_connection
}

output "resource_id" {
  description = "The resource ID of the hybrid connection."
  value       = azapi_resource.hybrid_connection.id
}
