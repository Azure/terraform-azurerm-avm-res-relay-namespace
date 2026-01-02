output "name" {
  description = "The name of the authorization rule."
  value       = azapi_update_resource.authorization_rule.name
}

output "resource" {
  description = "The full resource object of the authorization rule."
  value       = azapi_update_resource.authorization_rule
}

output "resource_id" {
  description = "The resource ID of the authorization rule."
  value       = azapi_update_resource.authorization_rule.id
}
