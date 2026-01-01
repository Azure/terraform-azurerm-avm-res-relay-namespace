# Authorization Rule Submodule

This submodule creates an authorization rule for an Azure Relay namespace.

## Usage

```hcl
module "auth_rule" {
  source = "./modules/authorization-rule"

  name                 = "my-auth-rule"
  relay_namespace_id   = azapi_resource.relay_namespace.id
  rights               = ["Listen", "Send"]
}
```

## Parameters

- `name` - The name of the authorization rule
- `relay_namespace_id` - The resource ID of the parent Relay namespace
- `rights` - List of rights (Listen, Send, Manage)
