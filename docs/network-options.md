# Azure Relay Namespace Module - Network Access Options

This module supports the following options for `public_network_access`:

| Value | Description |
|-------|-------------|
| `Enabled` | The relay namespace allows public network access. This is the default setting. |
| `Disabled` | The relay namespace blocks all public network access and requires private endpoints for connectivity. |
| `SecuredByPerimeter` | The relay namespace is secured by an Azure Network Perimeter. |

## Examples for Each Configuration

- [Default with Public Access](./examples/default/) - Demonstrates standard deployment with `public_network_access = "Enabled"`
- [Private Networking](./examples/private-networking/) - Shows how to deploy with `public_network_access = "Disabled"` and configure private endpoints
- [Secured By Perimeter](./examples/secured-by-perimeter/) - Illustrates how to use the `public_network_access = "SecuredByPerimeter"` option

## Network Perimeter Integration

The `SecuredByPerimeter` option requires that you have configured an [Azure Network Perimeter](https://learn.microsoft.com/en-us/azure/network-perimeter/) for your environment. This is a separate Azure service that needs to be set up independently.

When using the `SecuredByPerimeter` option:
1. Ensure your Network Perimeter is properly configured
2. The relay namespace must be linked to your Network Perimeter
3. Access is controlled by the Network Perimeter's policies
