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
