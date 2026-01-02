output "name" {
  description = "The name of the WCF relay."
  value       = azapi_resource.wcf_relay.name
}

output "resource" {
  description = "The full resource object of the WCF relay."
  value       = azapi_resource.wcf_relay
}

output "resource_id" {
  description = "The resource ID of the WCF relay."
  value       = azapi_resource.wcf_relay.id
}
