output "resource_id" {
  description = "The resource ID of the network rule set."
  value       = azapi_resource.network_rule_set.id
}

output "name" {
  description = "The name of the network rule set."
  value       = azapi_resource.network_rule_set.name
}

output "resource" {
  description = "The full resource object of the network rule set."
  value       = azapi_resource.network_rule_set
}
