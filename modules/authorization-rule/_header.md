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
