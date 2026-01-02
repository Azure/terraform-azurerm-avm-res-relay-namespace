output "location" {
  description = "The location of the Relay namespace."
  value       = azapi_resource.relay_namespace.location
}

output "name" {
  description = "The name of the Relay namespace."
  value       = azapi_resource.relay_namespace.name
}

output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = azapi_resource.private_endpoints
}

output "resource" {
  description = "The full resource object of the Relay namespace."
  value       = azapi_resource.relay_namespace
}

output "resource_id" {
  description = "The resource ID of the Relay namespace."
  value       = azapi_resource.relay_namespace.id
}
