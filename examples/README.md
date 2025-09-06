# Examples

This directory contains examples of how to use the Azure Relay Namespace module.

## Available Examples

- **[Default](./default/)**: Basic deployment of an Azure Relay Namespace with standard configuration
- **[Private Endpoint](./private-endpoint/)**: Azure Relay Namespace with private endpoints for secure networking

## Example Implementation Notes

- Each example is self-contained and deployable
- All examples use randomized naming to ensure uniqueness
- No manual input variables are required to deploy the examples

## Usage

Each example can be deployed by navigating to its directory and running:

```bash
terraform init
terraform plan
terraform apply
```

To destroy the resources when finished:

```bash
terraform destroy
```
