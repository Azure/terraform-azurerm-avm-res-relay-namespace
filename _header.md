# terraform-azurerm-avm-res-relay-namespace

This is a Terraform Azure Verified Module for creating and managing Azure Relay namespaces and their subresources.

## Features

- Creates Azure Relay namespaces with Standard SKU
- Supports managed identities (system-assigned and user-assigned)
- Private endpoint support
- Diagnostic settings integration
- Role-based access control (RBAC)
- Management locks
- Customer-managed keys (CMK) support
- Comprehensive tagging support

## Submodules

This module includes submodules for managing Relay namespace child resources:

- **authorization-rule**: Manage authorization rules for the namespace
- **hybrid-connection**: Create and manage hybrid connections
- **network-rule-set**: Configure network access rules and IP restrictions
- **wcf-relay**: Create and manage WCF relays

## Usage

### Basic Example

```hcl
module "relay_namespace" {
  source  = "Azure/avm-res-relay-namespace/azurerm"
  version = "x.x.x"

  location          = "eastus"
  name              = "my-relay-namespace"
  resource_group_id = azurerm_resource_group.example.id
  enable_telemetry  = true

  public_network_access = "Enabled"
  
  sku = {
    name = "Standard"
    tier = "Standard"
  }

  tags = {
    environment = "production"
  }
}
```

### Example with Subresources

```hcl
module "relay_namespace" {
  source = "Azure/avm-res-relay-namespace/azurerm"

  location          = "eastus"
  name              = "my-relay-namespace"
  resource_group_id = azurerm_resource_group.example.id
  enable_telemetry  = true
}

module "auth_rule" {
  source = "Azure/avm-res-relay-namespace/azurerm//modules/authorization-rule"

  name               = "RootManageSharedAccessKey"
  relay_namespace_id = module.relay_namespace.resource_id
  rights             = ["Listen", "Send", "Manage"]
}

module "hybrid_connection" {
  source = "Azure/avm-res-relay-namespace/azurerm//modules/hybrid-connection"

  name                          = "my-hybrid-connection"
  relay_namespace_id            = module.relay_namespace.resource_id
  requires_client_authorization = true
}
```

For more examples, see the `examples` directory.
