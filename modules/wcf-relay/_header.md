# WCF Relay Submodule

This submodule creates a WCF relay for an Azure Relay namespace.

## Usage

```hcl
module "wcf_relay" {
  source = "./modules/wcf-relay"

  name                          = "my-wcf-relay"
  relay_namespace_id            = azapi_resource.relay_namespace.id
  relay_type                    = "NetTcp"
  requires_client_authorization = true
  requires_transport_security   = true
  user_metadata                 = "some metadata"
}
```
