output "resource_id" {
  description = "The resource ID of the authorization rule."
  value       = azapi_resource.authorization_rule.id
}

output "name" {
  description = "The name of the authorization rule."
  value       = azapi_resource.authorization_rule.name
}

output "resource" {
  description = "The full resource object of the authorization rule."
  value       = azapi_resource.authorization_rule
}
