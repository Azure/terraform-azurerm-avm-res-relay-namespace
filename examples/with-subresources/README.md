# Azure Relay Namespace with Subresources Example

This example demonstrates how to use the Azure Relay Namespace module with its subresources:

- Authorization Rules
- Hybrid Connections
- WCF Relays
- Network Rule Sets

## Usage

```hcl
module "relay_namespace" {
  source = "Azure/avm-res-relay-namespace/azurerm"

  location          = "eastus"
  name              = "my-relay-namespace"
  resource_group_id = azurerm_resource_group.this.id
  enable_telemetry  = true
}

module "auth_rule" {
  source = "Azure/avm-res-relay-namespace/azurerm//modules/authorization-rule"

  name               = "RootManageSharedAccessKey"
  relay_namespace_id = module.relay_namespace.resource_id
  rights             = ["Listen", "Send", "Manage"]
}
```
