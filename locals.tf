locals {
  private_endpoints = {
    for key, endpoint in var.private_endpoints : key => merge(endpoint, {
      lock = endpoint.lock != null ? endpoint.lock : (lookup(var.private_endpoints_inherit_lock, key, true) ? var.lock : null)
      tags = endpoint.tags != null ? endpoint.tags : var.tags
    })
  }
  private_endpoint_network_interface_ids = [
    for key, endpoint in module.avm_interfaces.private_endpoints_azapi :
    lower("${coalesce(local.private_endpoints[key].resource_group_name, var.resource_group_id)}/providers/Microsoft.Network/networkInterfaces/${endpoint.body.properties.customNetworkInterfaceName}")
  ]
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
