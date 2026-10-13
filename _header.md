# terraform-azurerm-avm-res-relay-namespace

This is a Terraform Azure Verified Module for creating and managing Azure Relay namespaces and their subresources.

## Features

- Creates Azure Relay namespaces with Standard SKU
- Private endpoint support
- Diagnostic settings integration
- Role-based access control (RBAC)
- Management locks
- Comprehensive tagging support

## Submodules

This module includes submodules for managing Relay namespace child resources:

- **authorization-rule**: Manage authorization rules for the namespace
- **hybrid-connection**: Create and manage hybrid connections
- **network-rule-set**: Configure network access rules and IP restrictions
- **wcf-relay**: Create and manage WCF relays

## Private endpoints

Private endpoints retain the existing `pe-<namespace>-<key>` default names and use the `namespace` connection group. Supply a full resource group ID in `private_endpoints[*].resource_group_name` to use another resource group, and `location` to use the subnet's region. Static IP configurations default their member name to `namespace`.

NIC names must be unique within a resource group. Existing generated NIC names are preserved; if two effective names collide, supply a unique `network_interface_name` on the conflicting endpoint instead of renaming an existing NIC.

DNS zone groups are created only when zone IDs are supplied and `private_endpoints_manage_dns_zone_group` is true. Endpoint role assignments, lock names and lock notes are honored. An omitted endpoint lock inherits the namespace lock; set that endpoint's key to false in `private_endpoints_inherit_lock` to opt out. Endpoint tags inherit `tags` unless explicitly replaced, including with an empty map.

### Upgrade note

Previously ignored endpoint DNS zones, role assignments, locks, locations and resource groups now take effect. Review these existing inputs before upgrading. Namespace and endpoint resource addresses and default names are unchanged.

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
