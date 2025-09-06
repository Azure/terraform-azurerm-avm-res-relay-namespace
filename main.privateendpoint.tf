# Implement private endpoints using AVM interfaces
resource "azapi_resource" "private_endpoints" {
  for_each = module.avm_interfaces.private_endpoints_azapi

  location  = var.location
  name      = each.value.name
  parent_id = data.azurerm_resource_group.this.id
  type      = each.value.type
  body = {
    properties = {
      subnet = each.value.body.properties.subnet
      privateLinkServiceConnections = [
        {
          name = each.value.body.properties.privateLinkServiceConnections[0].name
          properties = {
            privateLinkServiceId = each.value.body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId
            groupIds             = ["namespace"]
          }
        }
      ]
      customNetworkInterfaceName = each.value.body.properties.customNetworkInterfaceName
      applicationSecurityGroups  = each.value.body.properties.applicationSecurityGroups
      ipConfigurations           = each.value.body.properties.ipConfigurations
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = each.value.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Create private DNS zone groups if var.private_endpoints_manage_dns_zone_group = true
resource "azapi_resource" "private_dns_zone_groups" {
  for_each = module.avm_interfaces.private_dns_zone_groups_azapi

  name           = each.value.name
  parent_id      = azapi_resource.private_endpoints[each.key].id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Implement locks for private endpoints
resource "azapi_resource" "private_endpoint_locks" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name           = each.value.name
  parent_id      = azapi_resource.private_endpoints[each.value.pe_key].id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Implement role assignments for private endpoints
resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name           = each.value.name
  parent_id      = azapi_resource.private_endpoints[each.value.pe_key].id
  type           = each.value.type
  body           = each.value.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
