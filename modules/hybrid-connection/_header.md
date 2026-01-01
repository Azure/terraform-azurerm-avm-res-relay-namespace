# Hybrid Connection Submodule

This submodule creates a hybrid connection for an Azure Relay namespace.

## Usage

```hcl
module "hybrid_connection" {
  source = "./modules/hybrid-connection"

  name                          = "my-hybrid-connection"
  relay_namespace_id            = azapi_resource.relay_namespace.id
  requires_client_authorization = true
  user_metadata                 = "some metadata"
}
```
