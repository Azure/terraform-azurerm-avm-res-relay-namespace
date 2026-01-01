# Network Rule Set Submodule

This submodule creates a network rule set for an Azure Relay namespace.

## Usage

```hcl
module "network_rule_set" {
  source = "./modules/network-rule-set"

  relay_namespace_id             = azapi_resource.relay_namespace.id
  default_action                 = "Deny"
  public_network_access          = "Enabled"
  trusted_service_access_enabled = true
  ip_rules = [
    {
      ipMask = "10.0.0.0/24"
      action = "Allow"
    }
  ]
}
```

## Parameters

- `relay_namespace_id` - The resource ID of the parent Relay namespace
- `default_action` - Default action when no rule matches (Allow/Deny)
- `public_network_access` - Public network access setting
- `ip_rules` - List of IP rules
- `trusted_service_access_enabled` - Enable trusted Azure service access
