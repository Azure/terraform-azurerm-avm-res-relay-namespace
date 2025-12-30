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

## Parameters

- `name` - The name of the WCF relay
- `relay_namespace_id` - The resource ID of the parent Relay namespace
- `relay_type` - Type of relay (NetTcp or Http)
- `requires_client_authorization` - Whether client authorization is required (default: true)
- `requires_transport_security` - Whether transport security is required (default: true)
- `user_metadata` - User metadata for the WCF relay
